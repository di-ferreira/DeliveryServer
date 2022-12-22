const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // e2e testing node events setup code
    },
    baseUrl: 'http://localhost:9000/',
  },
  component: {
    setupNodeEvents(on, config) {
      // component testing node events setup code
    },
  },
})