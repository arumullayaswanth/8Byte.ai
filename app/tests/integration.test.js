const request = require("supertest");

// only run when a real db is available (CI provides one, local usually doesn't)
const hasDb = !!process.env.DB_HOST;
const maybe = hasDb ? describe : describe.skip;

maybe("visits API (integration)", () => {
    let app;

    beforeAll(async () => {
        const { initSchema } = require("../src/db");
        await initSchema();
        app = require("../src/app").createApp();
    });

    test("POST then GET /visits round-trips through the db", async () => {
        const post = await request(app).post("/visits").send({ note: "ci-test" });
        expect(post.status).toBe(201);
        expect(post.body.note).toBe("ci-test");

        const get = await request(app).get("/visits");
        expect(get.status).toBe(200);
        expect(get.body.length).toBeGreaterThan(0);
    });
});
