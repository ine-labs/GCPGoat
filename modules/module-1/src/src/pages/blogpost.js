import React, { useState } from 'react';
import { Link as RouterLink, useLocation } from 'react-router-dom';
// @mui
// import { styled } from '@mui/material/styles';
import { Button, Typography, Container, Box, Card, CardMedia, Divider, Stack, Link, Snackbar } from '@mui/material';
// import CardActions from '@mui/material/CardActions';
import CardContent from '@mui/material/CardContent';
// import AccountCircleIcon from '@mui/icons-material/AccountCircle';
// components
import Page from '../components/Page';

import Iconify from '../components/Iconify';
import { getUser } from '../sections/auth/AuthService';
import awsLogoNew from '../images/aws.jpg';
import httpService from '../common/httpService';
import awsLogoWithName from '../images/aws-wname.jpg';
import logoName from '../images/logo-title.png';
import logo from '../images/gcp-logo.png';
import { Footer } from 'src/layouts/footer';
// import Button from '@mui/material/Button';
// import Typography from '@mui/material/Typography';

// ----------------------------------------------------------------------


// const ContentStyle = styled('div')(({ theme }) => ({
//   maxWidth: 480,
//   margin: 'auto',
//   minHeight: '100vh',
//   display: 'flex',
//   justifyContent: 'center',
//   flexDirection: 'column',
//   padding: theme.spacing(12, 0),
// }));

const getIcon = (name) => <Iconify icon={name} width={22} height={22} />;

const getDate = (isoStr) => {
  const date = new Date(isoStr);
  // const timestamp = date.getTime();
  // console.log(timestamp);
  // ${date.getHours()}:${date.getMinutes()} time is same for every post.
  return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()} `
}

const styleObj = {
  lineHeight: 1.80
};

const logoStyle={
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
  marginLeft: -17,
}

// ----------------------------------------------------------------------

export default function Blogpost() {
  const location = useLocation();
  const { authorName, getRequestImageData, postContent, postTitle, postingDate } = location.state || '';

  const [newAuthorName, setNewAuthorName] = useState(authorName)
  const [newGetRequestImageData, setGetRequestImageData] = useState(getRequestImageData)
  const [newPostContent, setNewPostContent] = useState(postContent)
  const [newPostTitle, setNewPostTitle] = useState(postTitle)
  const [newPostingDate, setNewPostDate] = useState(postingDate)
  const [success, setSuccess] = useState(false);
  const [message, setMessage] = useState(null);

  const user = getUser();
  const authLevel = user !== 'undefined' && user ? user.authLevel : '';
  const loggenInAuthLevel = authLevel;

  const [open, setOpen] = React.useState(false);

  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }

    setOpen(false);
  };

  function modifyPostStatus(event) {
    setNewAuthorName(newAuthorName)
    setGetRequestImageData(newGetRequestImageData)
    setNewPostContent(newPostContent)
    setNewPostTitle(newPostTitle)
    setNewPostDate(newPostingDate)
    let requestBody = {}
    // console.log(event.target.innerText)
    if (event.target.innerText === "Approve Post") {
      requestBody = {
        id: window.location.href.split('/')[window.location.href.split('/').length - 1],
        authLevel,
        postStatus: "approved"
      }
    } else {
      requestBody = {
        id: window.location.href.split('/')[window.location.href.split('/').length - 1],
        authLevel,
        postStatus: "rejected"
      }
    }
    // console.log(requestBody)

    httpService
      .post('/modify-post-status', requestBody)
      .then((response) => {
        setMessage(response.data.body)
        setSuccess(true)
      })
      .catch((error) => {
        console.error(error)
      })

  }

  return (
    <Page title="Blogs">
      <Stack direction="row" justifyContent="space-between" sx={{ backgroundColor: 'white' }} style={{boxShadow:'0 1px 3px rgba(15, 15, 15, 0.13)'}}>
        <Stack direction="row" justifyContent="flex-start" >
          <Link component={RouterLink} variant="subtitle2" to="/home" underline="hover">
            <div style={{display:'flex'}}>
            <img src={logo} style={{margin:10}} alt="" width="100px" />
            <div style={logoStyle}>
            <img src={logoName}  alt="" width="200px" />
            </div>
            </div>
          </Link>
        </Stack>
        <Stack direction="row" justifyContent="flex-end" alignItems="center" sx={{ paddingRight: 2 }}>
          {loggenInAuthLevel === "0" && (<><Button
            // onClick={() => UnbanUser()}
            variant="contained"
            color="success"
            component={RouterLink}
            to="#"
            sx={{ marginRight: '20px' }}
            startIcon={<Iconify icon="eva:person-done-fill" />}
            onClick={(e) => modifyPostStatus(e)}
          >
            Approve post
            {/* {userStatusOnBan === "active"? "Ban User":"Unban User"} */}
          </Button><Button
            // onClick={() => banUser()}
            variant="contained"
            color="error"
            component={RouterLink}
            to="#"
            startIcon={<Iconify icon="eva:person-delete-fill" />}
            onClick={(e) => modifyPostStatus(e)}

          >
              Reject post
              {/* {userStatusOnBan === "active"? "Ban User":"Unban User"} */}
            </Button></>)}
        </Stack>
      </Stack>
      <Container>
        <Card sx={{ minWidth: 275, mt: 7, mb: 7 }}>
          <CardMedia
            component="img"
            src={newGetRequestImageData}
            alt="Hello"
            sx={{ width: "100%" }}
          />
          <CardContent>
            <Container sx={{ alignItems: "center", justifyContent: "center", display: "flex" }}>
              <Container sx={{ borderRadius: "0%", width: "80%", alignItems: "center", justifyContent: "center", display: "flex", flexDirection: "column" }}>
                <Typography variant="h3" paragraph center>
                  {newPostTitle}
                </Typography>
                <Container sx={{ display: "flex", justifyContent: "center", alignItems: "center", flexDirection: "row" }}>
                  <Typography sx={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
                    <Box component="div" sx={{ p: 0.50 }}>{getIcon('bxs:user')}</Box> <Box component="div" sx={{ p: 1, mt: -0.25 }}>{newAuthorName}</Box>
                  </Typography>
                  <Typography sx={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
                    <Box component="div" display="inline" sx={{ p: 0.50 }}>{getIcon('fontisto:date')}</Box><Box component="div" sx={{ p: 1, mt: -0.25 }}>{getDate(newPostingDate)}</Box>
                  </Typography>
                </Container>
              </Container>
            </Container>
            <Divider sx={{ mt: 5, mb: 5 }} />
            <Container>
              {// eslint-disable-next-line
                <div dangerouslySetInnerHTML={{ __html: newPostContent }} style={styleObj} />}
            </Container>
          </CardContent>
        </Card>
      </Container>
      {/* <Stack direction="row" justifyContent="center" alignContent="center" sx={{ backgroundColor: 'black' }}>
        <img src={awsLogoWithName} alt="" width="200px" />
      </Stack> */}
      <Footer />
      <Snackbar open={success} autoHideDuration={4000} onClose={handleClose} message={message} />
    </Page>
  );
}
// display: -webkit-box;
// display: -webkit-flex;
// display: -ms-flexbox;
// display: flex;
// -webkit-box-pack: center;
// -webkit-justify-content: center;
// -ms-flex-pack: center;
// justify-content: center;
// -webkit-align-items: center;
// -webkit-box-align: center;
// -ms-flex-align: center;
// align-items: center;
// margin-left: -10px;