import "./assets/application.scss";
import "semantic-ui-css/semantic.css";
import 'izitoast/dist/css/iziToast.min.css'

import '@fullcalendar/core/main.css';
import '@fullcalendar/daygrid/main.css';
import '@fullcalendar/timegrid/main.css';
import '@fullcalendar/list/main.css';
import 'vue-directive-tooltip/css/index.css';

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

import VueClipboard from 'vue-clipboard2'
Vue.use(VueClipboard);

import * as VueGoogleMaps from 'vue2-google-maps'
Vue.use(VueGoogleMaps, {
  load: {
    key: 'AIzaSyADpGFHyrWnacLX76mVGcTKQ-HflkLHZm8'
  },
});

import VueSelect from "vue-cool-select";
Vue.use(VueSelect, {
  theme: "bootstrap"
});

import VueNotifications from 'vue-notifications'
import iziToast from 'izitoast'

function toast ({title, message, type, timeout, cb, position}) {
  if (type === VueNotifications.types.warn) type = 'warning'
   // bottomRight, bottomLeft, topRight, topLeft, topCenter, bottomCenter
  return iziToast[type]({title, message, timeout, position})
}

const options = {
  success: toast,
  error: toast,
  info: toast,
  warn: toast
}

Vue.use(VueNotifications, options)

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
      console.log(tableWidth)
      console.log(tableWrapper)

      document.querySelector("div.top-horizontal-scroll").style.width = tableWidth + "px";
      document.querySelector("div.top-scrollbar").style.width = tableWrapper + "px"
    }
  },

  notifications: {
    showSuccessMsg: {
      type: VueNotifications.types.success,
      title: 'Hello there',
      message: 'That\'s the success!',
      position: "topCenter"
    },
    showInfoMsg: {
      type: VueNotifications.types.info,
      title: 'Hey you',
      message: 'Here is some info for you',
      position: "topCenter"
    },
    showWarnMsg: {
      type: VueNotifications.types.warn,
      title: 'Wow, man',
      message: 'That\'s the kind of warning',
      position: "topCenter"
    },
    showErrorMsg: {
      type: VueNotifications.types.error,
      title: 'Wow-wow',
      message: 'That\'s the error',
      position: "topCenter"
    }
  },
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
