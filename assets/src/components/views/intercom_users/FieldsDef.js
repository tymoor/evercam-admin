import moment from "moment";

export default [
  {
    name: "link-to-company",
    title: ""
  },
  {
    name: 'username',
    title: 'Username',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'email',
    title: 'Email',
    sortField: 'email',
    togglable: true
  },
  {
    name: 'domain',
    title: 'Domain',
    sortField: 'domain',
    togglable: true
  },
  {
    name: 'status',
    title: 'Status',
    sortField: 'status',
    togglable: true
  },
  {
    name: 'created_at',
    title: 'Created At',
    sortField: 'created_at',
    togglable: true,
    formatter: (value) => {
      return dateFormat(value)
    }
  }
]

var dateFormat = (value) => {
  return moment.unix(value).format("dddd, DD MMM YYYY h:mm A");
}
