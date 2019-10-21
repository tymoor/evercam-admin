<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Account :</label>
        </div>
        <div class="col">
          <select v-model="account" @change="constructionFilterGlobal" class="form-control">
            <option value="owner_id=13959">Construction</option>
            <option value="owner_id=109148">Old Construction</option>
            <option value="owner_id=-1">Non Construction</option>
          </select>
        </div>
      </div>
    </form>
  </div>
</template>

<style scoped>
.form-control {
  box-shadow: none;
  -moz-box-shadow: none;
  -webkit-box-shadow: none;
}

.search-label {
  margin-top: 4px;
  margin-left: 15px;
}
</style>

<script>
export default {
  data () {
    return {
      account: "owner_id=13959",
      allParams: {}
    }
  },
  methods: {
    constructionFilterGlobal () {
      this.allParams.account = this.account
      this.$events.fire('construction-filter-set', this.allParams)
    }
  }
}
</script>