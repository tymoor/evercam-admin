export default [
  {
    name: 'created_at',
    title: 'Created At',
    sortField: 'created_at',
    togglable: true
  },
  {
    name: 'sharee_email',
    title: 'Sharee Email',
    sortField: 'sharee_email',
    togglable: true
  },
  {
    name: 'camera',
    title: 'Cameras',
    sortField: 'camera',
    togglable: true
  },
  {
    name: 'sharer',
    title: 'Sharer',
    sortField: 'sharer',
    togglable: true
  },
  {
    name: 'message',
    title: 'Message',
    togglable: true
  },,
  {
    name: 'rights',
    title: 'Rights',
    sortField: "rights",
    togglable: true
  },
  {
    name: 'status',
    title: 'Status',
    sortField: 'status',
    togglable: true,
    formatter: (value) => {
      return status(value)
    }
  }
]

var status;

status = (status) => {
  switch (status) {
    case -1:
      return "<span> Pending </span>"
    case -2:
      return "<span> Cancelled </span>"
    case 1:
      return "<span> Used </span>"
  }
}

  // PENDING                   = -1
  // CANCELLED                 = -2
  // USED                      = 1