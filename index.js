const Elm = require('./elm.js')

let app = Elm.Main.worker()
app.ports.sayHi.subscribe(function(messageFromElm) {
  console.log('Got message from elm', messageFromElm)
})
