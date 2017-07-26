const webpack = require('webpack')
const path = require('path')

module.exports = {
  entry: './src/elm-electron.ts',
  target: 'electron-renderer',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    publicPath: '/'
  },
  module: {
    loaders: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          {
            loader: 'elm-webpack-loader',
            options: {}
          }
        ]
      },
      { test: /\.ts$/, loader: 'ts-loader' }
    ]
  }
}
