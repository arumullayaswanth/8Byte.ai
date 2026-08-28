const { createApp } = require("./app");
const { initSchema } = require("./db");

const PORT = parseInt(process.env.PORT || "3000", 10);

(async () => {
    try {
        await initSchema();
        console.log("Schema ready");
    } catch (err) {
        // don't crash on startup if the db isn't up yet, let the platform retry
        console.error("Schema init failed (continuing):", err.message);
    }

    const app = createApp();
    app.listen(PORT, () => {
        console.log(`app listening on :${PORT}`);
    });
})();
