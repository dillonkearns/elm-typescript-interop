const Elm = require('./Main.elm')

let app = Elm.Main.worker()
app.ports.sayHi.subscribe(function(messageFromElm: any) {
  console.log('Got message from elm', messageFromElm)
})
