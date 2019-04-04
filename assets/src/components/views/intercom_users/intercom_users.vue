<template>
  <div>
    <div class="overflow-forms">
      <v-ic-filters />
    </div>
    <div>
      <v-ic-show-hide :vuetable-fields="vuetableFields" />
      <button class="btn btn-secondary mb-1 link-to-company" @click="linkUserToCompany" type="button">Link to Company</button>
      <button class="btn btn-secondary mb-1 link-custom-domains" @click="linkCustomDomains" type="button" v-tooltip.left="'This will link all users with their companies whom have custom domains.'">Link Cutsom Domains</button>
    </div>

    <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          :api-mode="false"
          :fields="fields"
          pagination-path="pagination"
          :per-page="perPage"
          :data-manager="dataManager"
          @vuetable:pagination-data="onPaginationData"
          @vuetable:initialized="onInitialized"
          @vuetable:loading="showLoader"
          @vuetable:loaded="hideLoader"
          :css="css.table"
        >
          <div slot="link-to-company" slot-scope="props">
            <input :value="props.rowData" type="checkbox" v-model="checkedIUsers" />
          </div>
        </vuetable>
      </div>
      <div class="vuetable-pagination ui bottom segment grid">
        <div class="field perPage-margin">
          <label>Per Page:</label>
          <select class="ui simple dropdown" v-model="perPage">
            <option :value="60">60</option>
            <option :value="100">100</option>
            <option :value="500">500</option>
            <option :value="1000">1000</option>
          </select>
        </div>
        <vuetable-pagination-info ref="paginationInfo"
        ></vuetable-pagination-info>
        <component :is="paginationComponent" ref="pagination"
          @vuetable-pagination:change-page="onChangePage"
        ></component>
      </div>
    </div>
</div>
</template>

<style scoped>
.perPage-margin {
  margin-top: 5px;
}

.overflow-forms {
  overflow: hidden;
  width: 85%;
}

#table-wrapper {
  margin-top: -2px;
}

.ui.compact.icon.button {
  padding: 5px;
  cursor: pointer;
}

.link-to-company {
  float: right;
  margin-top: -35px;
  margin-right: 50px;
}

.link-custom-domains {
  float: right;
  margin-top: -35px;
  margin-right: 170px;
}

</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import ICFilters from "./ic_filters";
import ICShowHide from "./ic_show_hide";
import moment from "moment";
import axios from "axios";
import _ from "lodash";

export default {
  components: {
    "v-ic-filters": ICFilters,
    "v-ic-show-hide": ICShowHide
  },
  data: () => {
    return {
      loading: "",
      perPage: 60,
      css: TableWrapper,
      moreParams: {},
      paginationComponent: "vuetable-pagination",
      fields: FieldsDef,
      data: [],
      filtered: [],
      checkedIUsers: [],
      ajaxWait: true,
    }
  },
  watch: {
    data(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.setData(this.data);
      });
    },
    filtered(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.setData(this.filtered);
      });
    },
    paginationComponent(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.pagination.setPaginationData(paginationData);
      });
    }
  },

  mounted() {
    this.ajaxWait = true
    axios.get("/v1/without_company_intercom_users").then(response => {
      this.data = response.data.data;
      this.ajaxWait = false
      this.filtered = response.data.data;
    });
    this.$events.$on('ic-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('ic-added', e => this.onICAdded())
  },

  methods: {


    linkCustomDomains () {
      this.ajaxWait = true
      let emails = ""
      let allData = this.data
      let willLink = true
      let nonCustomDomain = ["gmail.com", "ymail.com", "yahoo.com", "hotmail.com", "outlook.com", "live.com", "live.ie", "yahoo.co.uk", "mail.com", "google.com"]

      allData.forEach((user) => {
        let userEmail = user.email
        nonCustomDomain.forEach((domain) => {
          if (userEmail != null) {
            if (this.emailDomainCheck(userEmail, domain) === "1") {
              willLink = false
            }
          }
        });

        if (willLink === true) {
          if (userEmail != null) {
            if (emails === "") {
              emails += "" + userEmail + ""
            } else {
              emails += "," + userEmail + ""
            }
          }
        }
        willLink = true
      });

      if (emails != "") {
        this.$http.post("/v1/add_company_to_users", {...{emails: emails}}).then(response => {
          this.$notify({
            group: "admins",
            title: "Info",
            type: "success",
            text: "Users have been updated on Intercom!",
          });
          this.removeUpdateUsers(emails)
          this.ajaxWait = false
        }, error => {
          this.ajaxWait = false
          this.$notify({
            group: "admins",
            title: "Error",
            type: "error",
            text: "Something went wrong!",
          });
        });
      }
    },

    emailDomainCheck(email, domain) {
      var parts = email.split('@');
      if (parts.length === 2) {
          if (parts[1] === domain) {
              return "1";
          }
      }
      return "0";
    },

    onFilterSet (filter) {
      this.filtered = this.data.filter(d => {
        for (let name in d) {
          if ((d[name] + '').toLowerCase().indexOf(filter.search.toLowerCase()) > -1){
            return d;
          }
        }
      })
    },

    linkUserToCompany () {
      if (Object.keys(this.checkedIUsers).length === 0) {
        this.$notify({
          group: "admins",
          title: "Error",
          type: "error",
          text: "At least select one User!",
        });
      } else {
        this.ajaxWait = true
        let emails = ""
        this.checkedIUsers.map((user) => {
          if (emails === "") {
            emails += "" + user.email + ""
          } else {
            emails += "," + user.email + ""
          }
        });

        this.$http.post("/v1/add_company_to_users", {...{emails: emails}}).then(response => {
          this.$notify({
            group: "admins",
            title: "Info",
            type: "success",
            text: "Users have been updated on Intercom!",
          });
          this.checkedIUsers = []
          this.removeUpdateUsers(emails)
          this.ajaxWait = false
        }, error => {
          this.ajaxWait = false
          this.$notify({
            group: "admins",
            title: "Error",
            type: "error",
            text: "Something went wrong!",
          });
        });
      }
    },

    removeUpdateUsers(emails) {
      let newData = this.data;
      let filteredData = this.filtered
      let email_array = emails.split(",");
      for (var i = 0; i < newData.length; i++) {

        email_array.forEach((email) => {
          if (newData[i].email === email) {
            newData.splice(i, 1)
          }
        })
      }

      for (var i = 0; i < filteredData.length; i++) {

        email_array.forEach((email) => {
          if (filteredData[i].email === email) {
            filteredData.splice(i, 1)
          }
        })
      }
      this.data = newData
      this.filtered = filteredData
    },

    onICAdded () {
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onPaginationData(paginationData) {
      this.$refs.pagination.setPaginationData(paginationData);
    },

    onChangePage(page) {
      this.$refs.vuetable.changePage(page);
    },

    dataManager(sortOrder, pagination) {
      if (this.data.length < 1) return;

      let local = this.data;

      // sortOrder can be empty, so we have to check for that as well
      if (sortOrder.length > 0) {
        console.log("orderBy:", sortOrder[0].sortField, sortOrder[0].direction);
        local = _.orderBy(
          local,
          sortOrder[0].sortField,
          sortOrder[0].direction
        );
      }

      pagination = this.$refs.vuetable.makePagination(
        local.length,
        this.perPage
      );
      console.log('pagination:', pagination)
      let from = pagination.from - 1;
      let to = from + this.perPage;

      return {
        pagination: pagination,
        data: _.slice(local, from, to)
      };
    },

    onInitialized(fields) {
      this.vuetableFields = fields.filter(field => field.togglable);
    },

    showLoader() {
      this.loading = "loading";
    },

    hideLoader() {
      this.loading = "";
    }
  }
}
</script>