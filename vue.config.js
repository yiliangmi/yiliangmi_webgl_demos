const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
    publicPath: './',
    outputDir: 'dist',
    assetsDir: 'assets',
    transpileDependencies: true,
    configureWebpack: (config) => {
        config.module.rules.push({
            test: /\.glsl$/,

            use: [
                {
                    loader: "webpack-glsl-loader",
                },
            ],
        });
    },
})
