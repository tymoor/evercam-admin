import "./assets/application.scss"

import Vue from 'vue'
import App from './App.vue'
import Login from './components/Login.vue'
import router from './router'
import adminRouter from './components/adminRouter'
import store from './store'

import "jquery/dist/jquery"
import "popper.js"
import "bootstrap/dist/js/bootstrap";
import "@coreui/coreui/dist/js/coreui";

Vue.config.productionTip = false

document.addEventListener('DOMContentLoaded', () => {

  if(document.getElementById("login")){
    new Vue({
      adminRouter,
      render: h => h(Login),
    }).$mount('#login')
  }

  if(document.getElementById("app")){
    const node = document.getElementById('app');
    const current_user = JSON.parse(node.getAttribute('current_user'));
    // const api_url = node.getAttribute('api_url');

    new Vue({
      router,
      store,
      render: h => h(App),
      data: {
        user: current_user
      }
    }).$mount('#app')
  }
});
