import React from "react";
// import { useMediaQuery } from "react-responsive";
import styled from "styled-components";
import logoName from '../../images/logo-title.png';
import logo from '../../images/full-logo.png';
import HomepageAccountPopover from '../dashboard/HomepageAccountPopover';
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
  box-shadow: 0px -2px 13px -1px rgba(0,0,0,0.33);
  display: flex;
  align-items: center;
  justify-content: center;
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
  position:absolute;
  bottom:0;
`;
const LogoNameInner = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
`;



export function Footer({scriptValue,handleChange}) {


  return (
    <NavbarContainer>
      <LogoNameInner >
      <img src={logo} alt="" width="140px" />
      <div className="post-type-link">
      By <a href="https://ine.com"> INE</a>
      </div>
      </LogoNameInner>
    </NavbarContainer>
  );
}
