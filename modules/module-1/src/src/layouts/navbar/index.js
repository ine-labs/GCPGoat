import React from "react";
// import { useMediaQuery } from "react-responsive";
import styled from "styled-components";
import logoName from '../../images/logo-title.png';
import logo from '../../images/gcp-logo.png';
import HomepageAccountPopover from '../../layouts/dashboard/HomepageAccountPopover';
import { Stack, InputBase } from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import { styled as st, alpha } from '@mui/material/styles';
// import { Logo } from "../logo";
// import { Accessibility } from "./accessibility";
// import { NavLinks } from "./navLinks";
// import { DeviceSize } from "../responsive";
// import { MobileNavLinks } from "./mobileNavLinks";

const NavbarContainer = styled.div`
  width: 100%;
  height: 65px;
  box-shadow: 0 1px 3px rgba(15, 15, 15, 0.13);
  display: flex;
  align-items: center;
  padding: 0 1.5em;
`;

const LeftSection = styled.div`
  display: flex;
`;

const MiddleSection = styled.div`
  display: flex;
  flex: 2;
  height: 100%;
  justify-content: center;
`;

const RightSection = styled.div`
  display: flex;
  justify-content: flex-end;
  margin-left: auto;
  margin-right: 0;
`;
const LogoNameInner = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  margin-left: -10px;
`;

const Search = st('div')(({ theme }) => ({
    position: 'relative',
    borderRadius: theme.shape.borderRadius,
    backgroundColor: alpha(theme.palette.common.black, 0.15),
    '&:hover': {
      backgroundColor: alpha(theme.palette.common.black, 0.25),
    },
    marginLeft: 0,
    width: '100%',
    [theme.breakpoints.up('sm')]: {
      marginLeft: theme.spacing(1),
      width: 'auto',
    },
  }));

  const SearchIconWrapper = st('div')(({ theme }) => ({
    padding: theme.spacing(0, 2),
    height: '100%',
    position: 'absolute',
    pointerEvents: 'none',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  }));
  
  const StyledInputBase = st(InputBase)(({ theme }) => ({
    color: 'inherit',
    '& .MuiInputBase-input': {
      padding: theme.spacing(1, 1, 1, 0),
      // vertical padding + font size from searchIcon
      paddingLeft: `calc(1em + ${theme.spacing(4)})`,
      transition: theme.transitions.create('width'),
      width: '100%',
      [theme.breakpoints.up('sm')]: {
        width: '20ch',
        '&:focus': {
          width: '40ch',
        },
      },
    },
  }));

export function Navbar({scriptValue,handleChange}) {


  return (
    <NavbarContainer>
      <LeftSection>
      <img src={logo} alt="" width="100px" />
      <LogoNameInner >
      <img src={logoName} alt="" width="200px" />
      </LogoNameInner>
      
      </LeftSection>

      <RightSection>

      <Search sx={{ height: '40px', marginRight: 10 }}>
              <SearchIconWrapper>
                <SearchIcon sx={{ color: "black" }} />
              </SearchIconWrapper>
              <StyledInputBase
                placeholder="Search…"
                inputProps={{ 'aria-label': 'search' }}
                value={scriptValue}
                onChange={handleChange}
                sx={{ color: "black" }}
              />
            </Search>

        <HomepageAccountPopover />
      </RightSection>
    </NavbarContainer>
  );
}
