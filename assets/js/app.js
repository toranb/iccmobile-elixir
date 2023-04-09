// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let lastY = 0
let startY = 0
let diff = 0
let loading = false
const THRESHOLD = 50

const delta = () => lastY - startY
const pulling = () => startY && delta() > 0
const safeString = (el, value) => el.style.transform = `translate3d(0px, ${value}px, 0px)`

const transform = (el) => {
  if (pulling()) {
    safeString(el, diff)
  } else if (loading) {
    safeString(el, THRESHOLD)
  } else {
    safeString(el, 0)
  }
}

let Hooks = {}
Hooks.Pull = {
  mounted() {
    const pull = document.getElementById('pull')
    const pullChild = document.getElementById('pull-child')
    const setTransform = () => {
      transform(pullChild)
    }

    setTransform()

    this.handleEvent('refreshed', () => {
      loading = false
      setTransform()
    })

    pull.addEventListener('touchmove', (e) => {
      if (loading) {
        return
      }

      lastY = e.targetTouches[0].pageY

      if (!pulling()) {
        return
      }

      diff = Math.min(delta(), (THRESHOLD * 2))
      setTransform()
    }, false)

    pull.addEventListener('touchstart', (e) => {
      const atTop = document.body.scrollTop === 0

      if (loading || !atTop) {
        return
      }

      const y = e.targetTouches[0].pageY

      lastY = y
      startY = y

      setTransform()
    }, false)

    pull.addEventListener('touchend', (e) => {
      const refreshing = delta() >= THRESHOLD

      if (refreshing) {
        loading = true
        this.pushEvent('refresh')
      }

      lastY = 0
      startY = 0

      setTransform()
    }, false)
  },
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

