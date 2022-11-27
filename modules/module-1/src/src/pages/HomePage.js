// import React from "react";
import React, { useState, useEffect } from 'react';
// import Snackbar from '@mui/material/Snackbar';
import { styled, alpha } from '@mui/material/styles';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
// import axios from 'axios';
import { Link } from 'react-router-dom';
import { Stack, InputBase } from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import SearchNotFound from '../components/SearchNotFound';
import HomepageAccountPopover from '../layouts/dashboard/HomepageAccountPopover';
import Page from '../components/Page';
import awsLogo from '../images/AWScloudtitle.jpg';
import awsLogoNew from '../images/aws.jpg';
import awsLogoWithName from '../images/aws-wname.jpg';
import { getToken } from '../sections/auth/AuthService';

import './App.css';
import httpService from '../common/httpService';
import { Navbar } from 'src/layouts/navbar';
import { Footer } from 'src/layouts/footer';

// const postsUrl = 'https://108u32xo9b.execute-api.us-east-1.amazonaws.com/data/list-posts';
// const requestUrl = 'https://108u32xo9b.execute-api.us-east-1.amazonaws.com/data/xss';

const getDate = (isoStr) => {
  const date = new Date(isoStr);
  // const timestamp = date.getTime();
  // console.log(timestamp);
  // ${date.getHours()}:${date.getMinutes()} time is same for every post.
  return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()} `
}


const Search = styled('div')(({ theme }) => ({
  position: 'relative',
  borderRadius: theme.shape.borderRadius,
  backgroundColor: alpha(theme.palette.common.white, 0.15),
  '&:hover': {
    backgroundColor: alpha(theme.palette.common.white, 0.25),
  },
  marginLeft: 0,
  width: '100%',
  [theme.breakpoints.up('sm')]: {
    marginLeft: theme.spacing(1),
    width: 'auto',
  },
}));

const SearchIconWrapper = styled('div')(({ theme }) => ({
  padding: theme.spacing(0, 2),
  height: '100%',
  position: 'absolute',
  pointerEvents: 'none',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
}));

const StyledInputBase = styled(InputBase)(({ theme }) => ({
  color: 'inherit',
  '& .MuiInputBase-input': {
    padding: theme.spacing(1, 1, 1, 0),
    // vertical padding + font size from searchIcon
    paddingLeft: `calc(1em + ${theme.spacing(4)})`,
    transition: theme.transitions.create('width'),
    width: '100%',
    [theme.breakpoints.up('sm')]: {
      width: '12ch',
      '&:focus': {
        width: '40ch',
      },
    },
  },
}));

function HomePage() {
  const [scriptValue, setScriptValue] = useState('');
  // const [result, setResult] = useState();
  // const [open, setOpen] = React.useState(false);
  const [POSTS, setddbposts] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  let notFoundValue = false
  //   const imagesArr = [
  //     one,
  //     two,
  //     three,
  //     four,
  //     five,
  //     six,
  //     seven,
  //     eight,
  //     nine,
  //     ten,
  //     eleven,
  //     twelve,
  //   ];

  const handleChange = (event) => {
    setScriptValue(event.target.value);
    setSearchTerm(event.target.value);
  };

  // const handleClose = (event, reason) => {
  //   if (reason === 'clickaway') {
  //     return;
  //   }

  //   setOpen(false);
  // };

  useEffect(() => {
    httpService
      .post('/list-posts')
      .then((response) => {
        // console.log('Response posts', response);
        setddbposts(response.data.body);
        // console.log(response.data.body.Items.userStatus);
        // setUserStatusOnBan("bannn", response.data.body.Items.userStatus);
      })
      .catch((error) => {
        console.error(error);
      });
  }, []);

  // function handleSubmit(scriptValue) {
  //   // console.log(scriptValue)
  //   const requestBody = {
  //     scriptValue,
  //   };

  //   axios
  //     .post(requestUrl, requestBody)
  //     .then((response) => {
  //       setResult(response.data.value);
  //       setOpen(true);
  //       // console.log("RESPONSESS ", response.data.value);
  //     })
  //     .catch((error) => {
  //       console.log(error);
  //     });
  // }

  return (
    <>
      <Page title="Homepage" >
        <Navbar scriptValue={scriptValue} handleChange={handleChange}/>

        {(searchTerm !== '' || notFoundValue) && (<Stack direction="column" justifyContent="center" spacing={{ xs: 0.5, sm: 1.5 }} sx={{ my: 5, px: 3 }}>
          <SearchNotFound searchQuery={searchTerm} />
        </Stack>)}
<div style={{minHeight:'100vh'}}>
        <>
<div className="body-card">
{POSTS.filter((post) => {
  if (post.postTitle.toLowerCase().includes(searchTerm.toLowerCase())) {
    return post;
  }
  notFoundValue = 1
  return 0;
}).map((post, index) => (
  <Link to={`/blogpost/${post.id}`} state={{ authorName: post.authorName, getRequestImageData: post.getRequestImageData, postContent: post.postContent, postTitle: post.postTitle, postingDate: post.postingDate, id: post.id }}>
  <Card sx={{ width:430,mt: 4, mb: 4 , borderRadius:0 }}>
    {/* <CardMedia
        component="img"
        image={post.getRequestImageData}
        alt="blog images"
      /> */}
      <CardMedia
            component="img"
            src={post.getRequestImageData}
            alt="Hello"
            sx={{ width: "100%" }}
          />
      <CardContent>
      
      {/* <Link to={`/blogpost/${post.id}`} state={{ authorName: post.authorName, getRequestImageData: post.getRequestImageData, postContent: post.postContent, postTitle: post.postTitle, postingDate: post.postingDate, id: post.id }}>
        <img src={post.getRequestImageData} alt="post" />
      </Link> */}
      <div className="post-type-link">
        <a href="#">Security</a>
      </div>
      <div className="card-title">{post.postTitle}</div>
      <div className="card-details">
        <ul>
          <li>By</li>
          <li>
            <a href="#">{post.authorName}</a>
          </li>
          <li>{getDate(post.postingDate)}</li>
        </ul>
      </div>
      </CardContent>
  </Card>
  </Link>
))}
</div>
        </>
        

        </div>



        {/* LOAD MORE */}
        {/* <div className="load-more-button">
        <button type="button">LOAD MORE</button>
      </div> */}



        {/* <Snackbar open={open} autoHideDuration={6000} onClose={handleClose} message={result} /> */}

        {/* FOOTER */}
        {/* <div className="footer">
        <div>AWS Goat</div>
      </div> */}
        {/* <Stack direction="column" alignSelf="flex-end">
          <Stack direction="row" justifyContent="center" sx={{ backgroundColor: 'black' }}>
            <img src={awsLogoWithName} alt="" width="200px" />
          </Stack>
        </Stack> */}
        <Footer />
      </Page>
    </>
  );
}

export default HomePage;
