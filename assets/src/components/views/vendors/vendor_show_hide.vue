<template>
  <div>
    <div class="show-hide-modal"><button class="btn btn-secondary mb-1" type="button" data-toggle="modal" data-target="#myModal"><i class="fa fa-columns"></i></button></div>
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true">
      <div class="modal-dialog modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Show/Hide Columns</h4>
            <button class="close" type="button" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">×</span>
          </button>
          </div>
          <div class="modal-body">
            <div v-if="vuetableFields" class="content">
              <div v-for="(field, idx) in vuetableFields" class="field" :key="idx">
                <div class="ui checkbox">
                  <input type="checkbox" :checked="field.visible" @change="toggleField(field, $event)">
                  <label>{{ getFieldTitle(field) }}</label>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" type="button" data-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.show-hide-modal {
  float: right;
  margin-top: -35px;
  margin-right: 13px;
}

.modal-dialog {
  width: 250px;
  margin-top: 114.5px;
}
</style>

<script>
export default {
  props: ['vuetableFields'],

  data() {
    return {
      visible: false
    };
  },

  computed: {
    vuetable() {
      return this.$parent.$refs.vuetable
    }
  },

  methods: {
    getFieldTitle(field) {
      if (typeof field.title === "function") return field.title(true);

      let title = field.title;
      if (title !== "") return this.stripHTML(title);

      return title;
    },

    stripHTML(str) {
      return str ? str.replace(/(<([^>]+)>)/gi, "") : "";
    },

    toggleField(field, event) {
      this.vuetable.toggleField(field.$_index);
    },

    show() {
      this.visible = true;
    },

    hide() {
      this.visible = false;
    }
  }
}
</script>