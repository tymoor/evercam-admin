import "./assets/application.scss"

import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import adminRouter from './admin/router.js'
import Login from "./admin/Login.vue"

import "jquery/dist/jquery"
import "popper.js"
import "bootstrap/dist/js/bootstrap";
import "@coreui/coreui/dist/js/coreui";

Vue.config.productionTip = false

// new Vue({
//   adminRouter,
//   store,
//   render: h => h(Login)
// }).$mount('#login')


document.addEventListener('DOMContentLoaded', () => {
  if(document.getElementById("login")){
    new Vue({
      adminRouter,
      store,
      render: h => h(Login)
    }).$mount('#login')
  }
});
