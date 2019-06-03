import moment from "moment";

export default [
  {
    name: 'exid',
    title: 'ID',
    sortField: 'exid',
    togglable: true
  },
  {
    name: 'camera_name',
    title: 'Camera',
    sortField: 'camera_name',
    togglable: true
  },
  {
    name: 'total_months',
    title: '# No',
    sortField: 'total_months',
    togglable: true
  },
  {
    name: 'oldest_snapshot_date',
    title: "Oldest Snapshot",
    titleClass: "snapshot_date",
    formatter: (value) => {
      return dateFormat(value)
    }
  },
  {
    name: 'latest_snapshot_date',
    title: "Latest Snapshot",
    titleClass: "snapshot_date",
    formatter: (value) => {
      return dateFormat(value)
    }
  },
  {
    name: '2015-jan',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-feb',
    title: 'F',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-mar',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-apr',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-may',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-jun',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-jul',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-aug',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-sep',
    title: 'S',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-oct',
    title: 'O',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-nov',
    title: 'N',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2015-dec',
    title: 'D',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-jan',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-feb',
    title: 'F',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-mar',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-apr',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-may',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-jun',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-jul',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-aug',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-sep',
    title: 'S',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-oct',
    title: 'O',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-nov',
    title: 'N',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2016-dec',
    title: 'D',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-jan',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-feb',
    title: 'F',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-mar',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-apr',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-may',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-jun',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-jul',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-aug',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-sep',
    title: 'S',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-oct',
    title: 'O',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-nov',
    title: 'N',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2017-dec',
    title: 'D',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-jan',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-feb',
    title: 'F',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-mar',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-apr',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-may',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-jun',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-jul',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-aug',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-sep',
    title: 'S',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-oct',
    title: 'O',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-nov',
    title: 'N',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2018-dec',
    title: 'D',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-jan',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-feb',
    title: 'F',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-mar',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-apr',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-may',
    title: 'M',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-jun',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-jul',
    title: 'J',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-aug',
    title: 'A',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-sep',
    title: 'S',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-oct',
    title: 'O',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-nov',
    title: 'N',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  },
  {
    name: '2019-dec',
    title: 'D',
    togglable: true,
    formatter: (value) => {
      return boxStoragePresence(value)
    }
  }
]

var boxStoragePresence;

boxStoragePresence = function(value) {
  if (value === 1) {
    return `<div class="input-color">
               <div class="color-box" style="background-color: #000000;"></div>
            </div>
            `;
  } else {
    return "";
  }
};

var dateFormat = (value) => {
  return moment(value).format("DD MMM YYYY h:mm A");
}
