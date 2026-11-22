module.exports = {
  apps: [
    {
      name: "royalbet-backend",
      script: "./server.js",
      env: { NODE_ENV: "production" }
    },
    {
      name: "royalbet-poker",
      script: "./pokerServer.js",
      env: { NODE_ENV: "production" }
    }
  ]
};
