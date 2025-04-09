// import { useSelector, useDispatch } from 'react-redux';     //error correction
import { setIsAuth } from '../Redux/action';
import React from 'react';
import logo from './Images/signinLogo.jpg';
import { useRef } from 'react';  //error correction
import { Link, useNavigate } from "react-router-dom";  //error correction

export const Login = () => {
    const emailRef = useRef(null);
    const passwordRef = useRef(null);
    const details = JSON.parse(localStorage.getItem('user-details'));
    const navigate = useNavigate();
    const dispatch = useDispatch();
    const isAuth = useSelector(state => state.isAuth);   //error correction

    /* const handleLogin = (e) => {
        e.preventDefault();
        const { email, password } = details || {};
        
        if (emailRef.current.value === email && passwordRef.current.value === password) {
            dispatch(setIsAuth(true));  // Correct dispatch with setIsAuth
            alert('Login successful');
            navigate('/');
        } else {
            alert("Login failed");
            navigate('/signin');
        }
    };  */ //error correction

    return (
        <>  
            <img 
                style={{
                    width: '200px',
                    height: 'fit-content',
                    objectFit: 'contain',
                    position: 'relative',
                    left: '43.5%',
                    paddingTop: '60px'
                }} 
                src={logo} 
                alt="logo" 
            />
            
            <div className="container" style={{
                maxWidth: "350px",
                height: 'fit-content',
                border: "1px solid lightgray",
                borderRadius: "5px",
                padding: "20px"
            }}>
                <div className="row">
                    <div className="panel panel-primary">
                        <div className="panel-body">
                            <form className="form" onSubmit={handleLogin}>
                                <div className="form-group">
                                    <h2 className="h2" style={{
                                        paddingBottom: "20px",
                                        fontWeight: "400",
                                        color: "black"
                                    }}>
                                        Log In
                                    </h2>
                                </div>
                                <div className="form-group">
                                    <label className="control-label" htmlFor="signupEmail" style={{
                                        paddingBottom: '10px',
                                        fontWeight: '500'
                                    }}>
                                        Email
                                    </label>
                                    <input 
                                        id="signupEmail" 
                                        type="email" 
                                        maxLength="50" 
                                        className="form-control" 
                                        ref={emailRef}
                                    />
                                </div>
                                <div className="form-group">
                                    <label className="control-label" htmlFor="signupPassword" style={{
                                        paddingBottom: '10px',
                                        fontWeight: '500'
                                    }}>
                                        Password
                                    </label>
                                    <input 
                                        id="signupPassword" 
                                        type="password" 
                                        maxLength="25" 
                                        className="form-control" 
                                        ref={passwordRef}
                                    />
                                </div>

                                <div className="form-group">
                                    <button 
                                        id="signupSubmit" 
                                        type="submit" 
                                        className="btn btn-info btn-block" 
                                        style={{
                                            margin: "20px 0 20px 0", 
                                            width: '306px',
                                            fontWeight: '400',
                                            fontSize: '14px',
                                            background: '#f77d0099',
                                            border: '1px solid #f77d0099'
                                        }}
                                    >
                                        LOG IN
                                    </button>
                                </div>
                                <p className="form-group" style={{
                                    fontWeight: "400",
                                    fontSize: "13px",
                                    lineHeight: "22px"
                                }}>
                                    By creating an account, you agree to our <a href="" style={{color: "blue"}}>Terms of Use</a> and our <a href="#" style={{color: "blue"}}>Privacy Policy</a>.
                                </p>
                                <hr/>
                            </form>
                        </div>
                    </div>         
                </div>
            </div>
            
            <div className="footerBox" style={{
                marginTop: "70px",
                background: "linear-gradient(180.47deg,rgba(196, 196, 196, 0.2) 0.41%,rgba(233, 228, 228, 0.2) 0.42%,rgba(250, 243, 243, 0) 99.59%)"
            }}>
                <div className="conditions" style={{
                    width: "350px",
                    marginTop: "30px",
                    display: "flex",
                    justifyContent: "space-evenly",
                    marginLeft: "39%",
                    fontSize: "13px",
                    lineHeight: "12px",
                    color: "#6366c4"
                }}>
                    <p>Conditions of Use</p>
                    <p>Privacy Notice</p>
                    <p>Help</p>
                </div>
                <div>
                    <p className="copyRight" style={{
                        fontWeight: "300",
                        fontSize: "13px",
                        lineHeight: "12px",
                        color: "#222222",
                        marginLeft: "45%",
                        position: "relative",
                        right: "40px"
                    }}>
                        &#169;1996-2021, Amazon.com, Inc. or its affilates
                    </p>
                </div>
            </div>
        </>
    );
};