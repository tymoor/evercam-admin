export default [
  {
    name: "custom-actions",
    title: "Actions",
    titleClass: "center aligned",
    dataClass: "center aligned"
  },
  {
    name: 'exid',
    title: 'ID',
    sortField: 'exid',
    togglable: true,
  },
  {
    name: 'name',
    title: 'Vendor',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'known_macs',
    title: 'Known Macs',
    togglable: true,
    formatter: (value) => {
      return displayMacs(value)
    }
  }
]

var displayMacs;

displayMacs = (macs) => {
  let all_macs = ""
  macs.map((mac) => {
    if (all_macs === "") {
      all_macs += "" + mac +""
    } else {
      all_macs += "," + mac +""
    }
  });
  return all_macs;
}
