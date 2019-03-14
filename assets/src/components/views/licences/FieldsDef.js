import moment from "moment";

export default [
  {
    name: 'email',
    title: 'Email',
    sortField: 'email',
    togglable: true
  },
  {
    name: 'name_link',
    title: 'Name',
    sortField: 'name_link',
    togglable: true
  },
  {
    name: 'country_name',
    title: 'Country',
    sortField: 'country_name',
    togglable: true
  },
  {
    name: 'description',
    title: 'Licence Description',
    sortField: 'description',
    togglable: true
  },
  {
    name: 'total_cameras',
    title: 'Cameras',
    sortField: 'total_cameras',
    togglable: true
  },
  {
    name: 'storage',
    title: 'Storage',
    sortField: 'storage',
    togglable: true
  },
  {
    name: 'period',
    title: 'Period',
    sortField: 'period',
    togglable: true
  },
  {
    name: 'created_at',
    title: 'Created Date',
    sortField: 'created_at',
    togglable: true
  },
  {
    name: 'start_date',
    title: 'Start Date',
    sortField: 'start_date',
    togglable: true
  },
  {
    name: 'end_date',
    title: 'End Date',
    sortField: 'end_date',
    togglable: true
  },
  {
    name: 'expiry',
    title: 'Expiry',
    sortField: 'expiry',
    togglable: true,
    formatter: (value) => {
      return Math.round(value)
    }
  },
  {
    name: 'amount',
    title: 'Amount',
    sortField: 'amount',
    togglable: true
  },
  {
    name: 'auto_renew',
    title: 'Auto Renew',
    sortField: 'auto_renew',
    togglable: true
  },
  {
    name: 'status',
    title: 'Status',
    sortField: 'status',
    togglable: true
  },
  {
    name: 'payment_method',
    title: 'Payment Method',
    sortField: 'payment_method',
    togglable: true
  }
]
