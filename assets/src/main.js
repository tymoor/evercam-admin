import "./assets/application.scss"

import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'

import "jquery/dist/jquery"
import "popper.js"
import "bootstrap/dist/js/bootstrap";
import "@coreui/coreui/dist/js/coreui";

Vue.config.productionTip = false

document.addEventListener('DOMContentLoaded', () => {

  if(document.getElementById("app")){
    // const node = document.getElementById('app');
    // const current_user = JSON.parse(node.getAttribute('current_user'));
    // const api_url = node.getAttribute('api_url');

    new Vue({
      router,
      store,
      render: h => h(App),
      data: {
        loggedIn: false
      }
    }).$mount('#app')
  }
});
