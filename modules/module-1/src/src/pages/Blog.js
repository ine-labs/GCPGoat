import React, { useEffect, useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
// material
// import { Grid, Button, Container, Stack, Typography } from '@mui/material';
import { Grid, Container, Button, Stack, Typography, Popper, Grow, Paper, MenuList, MenuItem } from '@mui/material';
import ButtonGroup from '@mui/material/ButtonGroup';
import { ArrowDropDownSharp } from '@mui/icons-material';
import ClickAwayListener from '@mui/material/ClickAwayListener';
// components
// import axios from 'axios';
import Page from '../components/Page';
import Iconify from '../components/Iconify';
// import { BlogPostCard, BlogPostsSort, BlogPostsSearch } from '../sections/@dashboard/blog';
// import { BlogPostCard, BlogPostsSearch } from '../sections/@dashboard/blog';
import { BlogPostCard } from '../sections/@dashboard/blog';
import { getUser } from '../sections/auth/AuthService';
import httpService from '../common/httpService';
// mock
// import POSTS from '../_mock/blog';

// ----------------------------------------------------------------------

// const requestUrl = "https://108u32xo9b.execute-api.us-east-1.amazonaws.com/data/list-posts";

const options = ['All Posts', 'Accepted Posts', 'Rejected Posts', 'Pending Posts'];


// const SORT_OPTIONS = [
//   { value: 'latest', label: 'Latest' },
//   { value: 'popular', label: 'Popular' },
//   { value: 'oldest', label: 'Oldest' },
// ];

// ----------------------------------------------------------------------
// console.log("POSTS...", POSTS)

export default function Blog() {
  const [POSTS, setddbposts] = useState([]);

  const [open, setOpen] = React.useState(false);
  const anchorRef = React.useRef(null);
  const [selectedIndex, setSelectedIndex] = React.useState(1);

  const user = getUser();
  const authLevel = user !== 'undefined' && user ? user.authLevel : '';
  const email = user !== 'undefined' && user ? user.email : '';

  const handleClick = () => {
    console.info(`You clicked ${options[selectedIndex]}`);
    let postStatus;
    if (options[selectedIndex] === "All Posts") {
      postStatus = "all";
    } else if (options[selectedIndex] === "Accepted Posts") {
      postStatus = "approved";
    } else if (options[selectedIndex] === "Rejected Posts") {
      postStatus = "rejected";
    } else {
      postStatus = "pending";
    }

    const requestBody = {
      authLevel, postStatus, email
    }
    console.log(requestBody)
    httpService
      .post('/list-posts', requestBody)
      .then((response) => {
        // console.log("Response posts", response)
        setddbposts(response.data.body);
        // console.log(response.data.body.Items.userStatus);
        // setUserStatusOnBan("bannn", response.data.body.Items.userStatus);
      })
      .catch((error) => {
        console.error(error);
      });
  };

  const handleMenuItemClick = (event, index) => {
    setSelectedIndex(index);
    setOpen(false);
  };

  const handleToggle = () => {
    setOpen((prevOpen) => !prevOpen);
  };

  const handleClose = (event) => {
    if (anchorRef.current && anchorRef.current.contains(event.target)) {
      return;
    }

    setOpen(false);
  };

  useEffect(
    () => {
      const newPostStatus = options[selectedIndex];
      const requestBody = {
        authLevel, 
        email,
        postStatus: "approved"
      }
      console.log(requestBody)
      httpService
        .post('/list-posts', requestBody)
        .then((response) => {
          console.log("Response posts", response)
          setddbposts(response.data.body);
          // console.log(response.data.body.Items.userStatus);
          // setUserStatusOnBan("bannn", response.data.body.Items.userStatus);
        })
        .catch((error) => {
          console.error(error);
        });
    }, []
  );


  return (
    <Page title="Posts">
      <Container>
        <Stack direction="row" alignItems="center" justifyContent="space-between" mb={5}>
          <Typography variant="h4" gutterBottom>
            Posts
          </Typography>
          <ButtonGroup variant="contained" color='secondary' ref={anchorRef} aria-label="split button">
            <Button onClick={handleClick}>{options[selectedIndex]}</Button>
            <Button
              size="small"
              aria-controls={open ? 'split-button-menu' : undefined}
              aria-expanded={open ? 'true' : undefined}
              aria-label="select merge strategy"
              aria-haspopup="menu"
              onClick={handleToggle}
            >
              <ArrowDropDownSharp />
            </Button>
          </ButtonGroup>
          <Popper
            open={open}
            anchorEl={anchorRef.current}
            role={undefined}
            transition
            sx={{ zIndex: 1 }}
            disablePortal
          >
            {({ TransitionProps, placement }) => (
              <Grow
                {...TransitionProps}
                style={{
                  transformOrigin:
                    placement === 'bottom' ? 'center top' : 'center bottom',
                }}
              >
                <Paper>
                  <ClickAwayListener onClickAway={handleClose}>
                    <MenuList id="split-button-menu" autoFocusItem>
                      {options.map((option, index) => (
                        <MenuItem
                          key={option}
                          // disabled={index === 2}
                          selected={index === selectedIndex}
                          onClick={(event) => handleMenuItemClick(event, index)}
                        >
                          {option}
                        </MenuItem>
                      ))}
                    </MenuList>
                  </ClickAwayListener>
                </Paper>
              </Grow>
            )}
          </Popper>
          <Button variant="contained" component={RouterLink} to="/dashboard/newpost" startIcon={<Iconify icon="eva:plus-fill" />}>
            New Post
          </Button>
        </Stack>

        {/* <Stack mb={5} direction="row" alignItems="center" justifyContent="space-between">
          <BlogPostsSearch posts={POSTS} />
          <BlogPostsSort options={SORT_OPTIONS} />
        </Stack> */}

        <Grid container spacing={3}>
          {POSTS.map((post, index) => (
            <BlogPostCard key={post.id} post={post} index={index} />
          ))}
        </Grid>
      </Container>
    </Page>
  );
}
