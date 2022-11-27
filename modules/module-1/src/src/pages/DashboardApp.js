import { useEffect, useState } from 'react';
import { faker } from '@faker-js/faker';
import { Grid, Container, Typography } from '@mui/material';
import { getUser } from '../sections/auth/AuthService';
// @mui
// import { useTheme } from '@mui/material/styles';
// components
import Page from '../components/Page';
// import Iconify from '../components/Iconify';
// sections
import {
  // AppTasks,
  // AppNewsUpdate,
  AppOrderTimeline,
  // AppCurrentVisits,
  AppWebsiteVisits,
  // AppTrafficBySite,
  AppWidgetSummary,
  // AppCurrentSubject,
  // AppConversionRates,
} from '../sections/@dashboard/app';
import httpService from '../common/httpService';

// ----------------------------------------------------------------------


export default function DashboardApp() {
  // const theme = useTheme();
  const [newChartLabel, setNewChartLabel] = useState([]);
  const [newChartData, setNewChartData] = useState([]);
  const [newChartRecentUsersName, setNewChartRecentUsersName] = useState('');
  const [newChartRecentUsersDates, setNewChartRecentUsersDates] = useState([]);
  const [totalPostsTab, setTotalPostsTab] = useState('');
  const [totalUsersTab, setTotalUsersTab] = useState('');
  const [recentPostsTab, setRecentPostsTab] = useState('');
  const user = getUser();
  const name = user !== 'undefined' && user ? user.name : '';
  
  useEffect(() => {
    httpService.post(('/get-dashboard')).then((response) => {
      const d = new Date();
      // console.log(response.data.body.chartData[d.getMonth()])
      console.log("Dashboard response", response);
      setNewChartRecentUsersDates(response.data.body.recentUserDates)
      setRecentPostsTab(response.data.body.chartData[d.getMonth()])
      setNewChartLabel(response.data.body.chartLabel)
      setNewChartData(response.data.body.chartData)
      setTotalPostsTab(response.data.body.totalPosts)
      setTotalUsersTab(response.data.body.totalUsers)
      setNewChartRecentUsersName(response.data.body.recentUserNames)
    }).catch((error) => {
      console.error("Dashboard error", error);
    })
  }, []);
  

  return (
    <Page title="Dashboard">
      <Container maxWidth="xl">
        <Typography variant="h4" sx={{ mb: 5 }}>
          Welcome back, {name}
        </Typography>

        <Grid container spacing={3}>
          <Grid item xs={12} sm={6} md={3}>
            <AppWidgetSummary title="Total Posts" total={Number(totalPostsTab)}  color="success"/>
          </Grid>

          {/* <Grid item xs={12} sm={6} md={2.4}>
            <AppWidgetSummary title="Total Views" total={1352831} color="success" icon={'ant-design:apple-filled'} />
          </Grid> */}

          <Grid item xs={12} sm={6} md={3}>
            <AppWidgetSummary title="Total Users" total={Number(totalUsersTab)} color="warning" />
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <AppWidgetSummary title="Recent Users" total={Number(newChartRecentUsersName.length)} color="info" />
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <AppWidgetSummary title="Recent Posts" total={Number(recentPostsTab)} color="error" />
          </Grid>

          <Grid item xs={12} md={6} lg={8}>
            <AppWebsiteVisits
              title="Post Analytics"
              subheader=""
              chartLabels={newChartLabel}
              chartData={[
                {
                  name: 'Posts',
                  type: 'area',
                  fill: 'solid',
                  data: newChartData,
                },
                // {
                //   name: 'Views',
                //   type: 'area',
                //   fill: 'gradient',
                //   data: [44, 55, 41, 67, 22, 43, 21, 41, 56, 27, 43],
                // },
                // {
                //   name: 'Team C',
                //   type: 'line',
                //   fill: 'solid',
                //   data: [30, 25, 36, 30, 45, 35, 64, 52, 59, 36, 39],
                // },
              ]}
            />
          </Grid>

          {/* <Grid item xs={12} md={6} lg={4}>
            <AppCurrentVisits
              title="Current Visits"
              chartData={[
                { label: 'America', value: 4344 },
                { label: 'Asia', value: 5435 },
                { label: 'Europe', value: 1443 },
                { label: 'Africa', value: 4443 },
              ]}
              chartColors={[
                theme.palette.primary.main,
                theme.palette.chart.blue[0],
                theme.palette.chart.violet[0],
                theme.palette.chart.yellow[0],
              ]}
            />
          </Grid> */}

          {/* <Grid item xs={12} md={6} lg={8}>
            <AppConversionRates
              title="Conversion Rates"
              subheader="(+43%) than last year"
              chartData={[
                { label: 'Italy', value: 400 },
                { label: 'Japan', value: 430 },
                { label: 'China', value: 448 },
                { label: 'Canada', value: 470 },
                { label: 'France', value: 540 },
                { label: 'Germany', value: 580 },
                { label: 'South Korea', value: 690 },
                { label: 'Netherlands', value: 1100 },
                { label: 'United States', value: 1200 },
                { label: 'United Kingdom', value: 1380 },
              ]}
            />
          </Grid> */}

          {/* <Grid item xs={12} md={6} lg={4}>
            <AppCurrentSubject
              title="Current Subject"
              chartLabels={['English', 'History', 'Physics', 'Geography', 'Chinese', 'Math']}
              chartData={[
                { name: 'Series 1', data: [80, 50, 30, 40, 100, 20] },
                { name: 'Series 2', data: [20, 30, 40, 80, 20, 80] },
                { name: 'Series 3', data: [44, 76, 78, 13, 43, 10] },
              ]}
              chartColors={[...Array(6)].map(() => theme.palette.text.secondary)}
            />
          </Grid> */}

          {/* <Grid item xs={12} md={6} lg={8}>
            <AppNewsUpdate
              title="News Update"
              list={[...Array(5)].map((_, index) => ({
                id: faker.datatype.uuid(),
                title: faker.name.jobTitle(),
                description: faker.name.jobTitle(),
                image: `/static/mock-images/covers/cover_${index + 1}.jpg`,
                postedAt: faker.date.recent(),
              }))}
            />
          </Grid> */}

          <Grid item xs={12} md={6} lg={4}>
            {/* {console.log(newChartRecentUsers)} */}
            {/* {console.log(Array(5).map((index, _) => console.log(index, _)))} */}
            <AppOrderTimeline
              title="Recent Users"
              list={[...Array(5)].map((_, index) => ({
                id: faker.datatype.uuid(),
                title: [newChartRecentUsersName][0][index],
                type: `order${index + 1}`,
                // time: [newChartRecentUsersDates][0],
              }))}
              />
              {/* {console.log(faker.date.past())} */}
          </Grid>

          {/* <Grid item xs={12} md={6} lg={4}>
            <AppTrafficBySite
              title="Traffic by Site"
              list={[
                {
                  name: 'FaceBook',
                  value: 323234,
                  icon: <Iconify icon={'eva:facebook-fill'} color="#1877F2" width={32} height={32} />,
                },
                {
                  name: 'Google',
                  value: 341212,
                  icon: <Iconify icon={'eva:google-fill'} color="#DF3E30" width={32} height={32} />,
                },
                {
                  name: 'Linkedin',
                  value: 411213,
                  icon: <Iconify icon={'eva:linkedin-fill'} color="#006097" width={32} height={32} />,
                },
                {
                  name: 'Twitter',
                  value: 443232,
                  icon: <Iconify icon={'eva:twitter-fill'} color="#1C9CEA" width={32} height={32} />,
                },
              ]}
            />
          </Grid> */}

          {/* <Grid item xs={12} md={6} lg={8}>
            <AppTasks
              title="Tasks"
              list={[
                { id: '1', label: 'Create FireStone Logo' },
                { id: '2', label: 'Add SCSS and JS files if required' },
                { id: '3', label: 'Stakeholder Meeting' },
                { id: '4', label: 'Scoping & Estimations' },
                { id: '5', label: 'Sprint Showcase' },
              ]}
            />
          </Grid> */}
        </Grid>
      </Container>
    </Page>
  );
}
