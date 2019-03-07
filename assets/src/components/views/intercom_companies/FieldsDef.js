import moment from "moment";

export default [
  {
    name: 'company_id',
    title: 'Company ID',
    togglable: true
  },
  {
    name: 'name',
    title: 'Name',
    togglable: true
  },
  {
    name: 'user_count',
    title: 'Users Count',
    togglable: true
  },
  {
    name: 'session_count',
    title: 'Sessions Count',
    togglable: true
  },
  {
    name: 'created_at',
    title: 'Created At',
    togglable: true,
    formatter: (value) => {
      return dateFormat(value)
    }
  }
]

var dateFormat = (value) => {
  return moment.unix(value).format("dddd, DD MMM YYYY h:mm A");
}
