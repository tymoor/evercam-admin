import "./assets/application.scss"
import "semantic-ui-css/semantic.css";

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

import {Vuetable, VuetablePagination, VuetablePaginationDropDown, VuetablePaginationInfo, VuetableFieldCheckbox} from "vuetable-2";
Vue.component("vuetable", Vuetable);
Vue.component("vuetable-pagination", VuetablePagination);
Vue.component("vuetable-pagination-dropdown", VuetablePaginationDropDown);
Vue.component("vuetable-pagination-info", VuetablePaginationInfo);
Vue.component('vuetable-field-checkbox', VuetableFieldCheckbox);

Vue.mixin({
  methods: {
    setScrollBar: () => {
      let tableWidth = document.querySelector("table.vuetable").offsetWidth;
      let tableWrapper = document.querySelector("div.vuetable-body-wrapper").offsetWidth;

      document.querySelector("div.top-horizontal-scroll").style.width = tableWidth + "px";
      document.querySelector("div.top-scrollbar").style.width = tableWrapper + "px"
    }
  }
})

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
    const api_url = node.getAttribute('api_url');

    new Vue({
      router,
      store,
      render: h => h(App),
      data: {
        user: current_user,
        api_url: api_url
      }
    }).$mount('#app')
  }
});
