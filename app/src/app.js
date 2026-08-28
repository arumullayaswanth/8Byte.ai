const express = require("express");
const { pool } = require("./db");
const { register, metricsMiddleware } = require("./metrics");

function createApp() {
    const app = express();
    app.use(express.json());
    app.use(metricsMiddleware);

    // keep this cheap so the ALB health check doesn't fail on a db hiccup
    app.get("/health", (_req, res) => {
        res.status(200).json({ status: "ok" });
    });

    app.get("/ready", async (_req, res) => {
        try {
            await pool.query("SELECT 1");
            res.status(200).json({ status: "ready" });
        } catch (err) {
            res.status(503).json({ status: "not-ready", error: err.message });
        }
    });

    app.get("/metrics", async (_req, res) => {
        res.set("Content-Type", register.contentType);
        res.end(await register.metrics());
    });

    app.post("/visits", async (req, res) => {
        const note = (req.body && req.body.note) || "hello from 8byte";
        const result = await pool.query(
            "INSERT INTO visits (note) VALUES ($1) RETURNING id, note, created_at",
            [note]
        );
        res.status(201).json(result.rows[0]);
    });

    app.get("/visits", async (_req, res) => {
        const result = await pool.query(
            "SELECT id, note, created_at FROM visits ORDER BY id DESC LIMIT 20"
        );
        res.status(200).json(result.rows);
    });

    return app;
}

module.exports = { createApp };
