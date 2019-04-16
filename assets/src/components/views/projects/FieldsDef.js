import moment from "moment";

export default [
  {
    name: "project-actions",
    title: 'Actions'
  },
  {
    name: "name",
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: "owner",
    title: 'Owner',
    togglable: true
  },
  {
    name: 'exid',
    title: 'Project ID',
    sortField: 'exid',
    togglable: true
  },
  {
    name: 'cameras',
    title: 'Cameras Count',
    sortField: 'cameras',
    togglable: true
  },
  {
    name: 'inserted_at',
    title: 'Created At',
    sortField: 'inserted_at',
    togglable: true
  }
]
