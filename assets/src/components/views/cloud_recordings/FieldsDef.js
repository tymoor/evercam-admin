import moment from "moment"
import accounting from "accounting"

export default [
  {
    name: 'camera_name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'camera_link',
    title: 'Onwer',
    sortField: 'firstname',
    togglable: true
  },
  {
    name: 'status',
    title: 'Status',
    sortField: 'status',
    togglable: true
  },
  {
    name: 'storage_duration',
    title: 'Duration',
    sortField: 'storage_duration',
    togglable: true
  },
  {
    name: 'interval',
    title: 'Interval # / min',
    sortField: 'interval',
    togglable: true
  },
  {
    name: 'schedule',
    title: 'Schedule HPW',
    sortField: 'schedule',
    togglable: true
  },
  {
    name: 'online',
    title: 'Online',
    sortField: 'online',
    togglable: true,
    formatter: (value) => {
      return booleans(value)
    }
  },
  {
    name: 'public',
    title: 'Public',
    sortField: 'public',
    togglable: true,
    formatter: (value) => {
      return booleans(value)
    }
  },
  {
    name: 'licences',
    title: 'Licenced',
    sortField: 'licences',
    togglable: true
  },
  {
    name: 'payment_method',
    title: 'Type',
    sortField: 'payment_method',
    togglable: true,
    formatter: (value) => {
      return paymentMethod(value)
    }
  }
]

var paymentMethod, booleans;

booleans = (name) => {
  switch (name) {
    case true:
      return "<span class='text-success'> True </span>"
    case false:
      return "<span class='text-danger'> False </span>"
    default:
      return ""
  }
}

paymentMethod = function(name) {
  switch (name) {
    case 0:
      return "Stripe";
    case 1:
      return "Custom";
    case 2:
      return "Construction";
    case 3:
      return "Gardai";
    case 4:
      return "Smart Cities";
    default:
      return "Unknown";
  }
};