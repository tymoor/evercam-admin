export default {
  'filter': (app, vuetable, payload) => {
    let str = payload.map((f) => `filters[]=${f.key}|${f.value}`).join('&')
    console.log('filter:', payload, str)
  }
}