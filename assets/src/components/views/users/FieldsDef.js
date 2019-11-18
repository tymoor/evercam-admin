import moment from "moment"
import accounting from "accounting"

export default [
  {
    name: "checkbox-slot",
    title: "",
    titleClass: "user-checkbox"
  },
  {
    name: 'payment_method', 
    title: "Type",
    sortField: 'payment_method',
    togglable: true,
    formatter: (value) => {
      return paymentMethod(value)
    },
    filterable: true,
    filterType: "select",
    filterName: "payment_method",
    selectOptions: [
      {value: "", name: "All", selected: "true"},
      {value: "0", name: "Stripe"},
      {value: "1", name: "Custom"},
      {value: "2", name: "Construction"},
      {value: "3", name: "Gardai"},
      {value: "4", name: "Smart Cities"},
      {value: "5", name: "Unknown"},
    ]
  },
  {
    name: 'username',
    title: 'Username',
    sortField: 'username',
    togglable: true,
    visible: false
  },
  {
    name: 'name_link',
    title: 'Name',
    sortField: 'fullname',
    togglable: true,
    filterable: true,
    filterType: "text",
    filterName: "fullname"
  },
  {
    name: 'social',
    title: 'Social',
    togglable: true
  },
  {
    name: 'email',
    title: 'Email',
    sortField: 'email',
    togglable: true,
    filterable: true,
    filterType: "text",
    filterName: "email"
  },
  {
    name: 'api_id',
    title: 'API ID',
    sortField: 'api_id',
    togglable: true,
    visible: false
  },
  {
    name: 'api_key',
    title: 'API Key',
    sortField: 'api_key',
    togglable: true,
    visible: false
  },
  {
    name: 'company_name',
    title: "Company",
    sortField: 'company_name',
    togglable: true,
    filterable: true,
    filterType: "text",
    filterName: "company_name"
  },
  {
    name: 'total_cameras',
    title: 'Total Cams',
    sortField: 'total_cameras',
    togglable: true,
    filterable: true,
    filterType: "text",
    filterName: "total_cameras"
  },
  {
    name: 'cameras_owned',
    title: '# Owned',
    sortField: 'cameras_owned',
    togglable: true,
    filterable: true,
    filterType: "text",
    filterName: "cameras_owned"
  },
  {
    name: 'camera_shares',
    title: '# Shared',
    sortField: 'camera_shares',
    togglable: true,
    filterable: true,
    filterType: "text",
    filterName: "camera_shares"
  },
  {
    name: 'snapmail_count',
    title: 'Snapmail Count',
    sortField: 'snapmail_count',
    togglable: true
  },
  {
    name: 'country',
    title: 'Country',
    sortField: 'country',
    togglable: true,
    filterable: true,
    filterType: "text",
    filterName: "country"
  },
  {
    name: 'created_at',
    title: 'Registered',
    sortField: 'created_at',
    togglable: true
  },
  {
    name: 'last_login_at',
    title: 'Last Login At',
    sortField: 'last_login_at',
    togglable: true,
    filterable: true,
    filterType: "select",
    filterName: "last_login_at_boolean",
    selectOptions: [
      {value: "true", name: "True"},
      {value: "false", name: "False"},
      {value: "whatever", name: "Whatever", selected: "true"}
    ]
  },
  {
    name: 'referral_url',
    title: 'Referral URL',
    sortField: 'referral_url',
    togglable: true
  }
]

var paymentMethod;

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