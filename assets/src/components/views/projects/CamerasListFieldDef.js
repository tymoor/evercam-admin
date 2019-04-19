import moment from "moment";
import accounting from "accounting"

export default [
  {
    name: "cameras-list-action",
    title: '',
    width: '30px'
  },
  {
    name: 'created_at',
    title: 'Created At',
    sortField: 'created_at',
    togglable: true
  },
  {
    name: 'exid',
    title: 'ID',
    sortField: 'exid',
    togglable: true
  },
  {
    name: 'camera_link',
    title: 'Owner',
    sortField: 'fullname',
    togglable: true
  },
  {
    name: 'owner_email',
    title: 'Email',
    sortField: 'owner_email',
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
  },
  {
    name: 'name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: "is_online",
    title: 'Online',
    sortField: 'is_online',
    togglable: true,
    width: '80px',
    formatter: (value) => {
      return booleans(value)
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