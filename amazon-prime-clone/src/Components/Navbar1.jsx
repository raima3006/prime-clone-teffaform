import React from "react";
import styles from "./Styles/Navbar1.module.css";
import Primelogo from "./Images/Primelogo.svg";
import LanguageEnLogo from "./Images/Nav1_Language.svg";
import { Link } from "react-router-dom";
import { Homepage } from './HomepageBeforeLogin';

// Changed from named export to default export
const Navbar1 = () => {
  return (
    <div className={styles.nav1_mainDiv}>
      <div className={styles.nav1_leftDiv_primelogo}>
        <Link to={Homepage}>
          <img 
            className={styles.nav1_img} 
            src={Primelogo} 
            alt="Prime logo" 
          />
        </Link>
      </div>
      
      <div className={styles.nav1_rightDiv}>
        <div className={styles.nav1_rightDiv_language}>
          <img 
            className={styles.nav1_img} 
            src={LanguageEnLogo} 
            alt="Language selector" 
          />
        </div>
        
        <div className={styles.nav1_rightDiv_signIn}>
          <Link 
            className={styles.nav1_rightDiv_signIn_link} 
            to="/signin"
            aria-label="Sign In"
          >
            Sign In
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Navbar1; // This is the key change