import moment from "moment";

export default [
  {
    name: "company-actions",
    title: 'Actions'
  },
  {
    name: 'company_id',
    title: 'Company ID',
    sortField: 'company_id',
    togglable: true
  },
  {
    name: "name",
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'user_count',
    title: 'Users Count',
    sortField: 'user_count',
    togglable: true
  },
  {
    name: 'session_count',
    title: 'Sessions Count',
    sortField: 'session_count',
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
