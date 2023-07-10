// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import 'openzeppelin-contracts/contracts/access/Ownable.sol';
import 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import '../Interface/IHyperclaimVerifiersCurator.sol';

// #TODO

// Curator manages the addition of verifiers to the verifiers registry via application and voting

contract TokenCuratedRegistry {

  	////////////////
    // EVENTS
    ////////////////

    event ApplicationCreated(uint256 indexed applicationId, address indexed submitter, string data);
    event ApplicationVoted(uint256 indexed applicationId, address indexed voter, uint256 voteCount);
    event ApplicationAccepted(uint256 indexed applicationId);
    event ApplicationRejected(uint256 indexed applicationId);

  	////////////////
    // ERRORS
    ////////////////

	error NotVerifier();
	error InelligibleApplicant();
	error InsufficientTokens();
	error AlreadyVoted();
	error ApplicationProcessed();
	error InvalidApplication();
	error VotingOpen();

  	////////////////
    // STATE
    ////////////////

	enum Status {
		REVIEWING;
		ACCEPTED;
		REJECTED;
	} 

	// Config	
    IERC20 public _votingToken; // IERC20 _votingToken used for voting
    uint256 public _applicationDeposit; // Minimum number of tokens required as a deposit for application
    uint256 public _votingPeriod; // Duration of the voting period in seconds

    struct Application {
        address submitter; 	// Address of the application creator
        string data; 		// Data associated with the application
        uint256 deposit; 	// Number of tokens staked as deposit
        uint256 voteCount; 	// Number of votes received
        Status status; 		// Whether the application is accepted or rejected
    }

    Application[] public applications; // Array of all applications

    mapping(address => uint256) public balances; // Mapping of _votingToken balances for each participant
    mapping(address => mapping(uint256 => bool)) public hasVoted; // Mapping to track whether a participant has voted on a application

  	////////////////
    // MODIFIERS
    ////////////////

    // Ensure the subject is a verifier
    modifier onlyVerifier(
		address verifier
	) {
        if (_verifiersByAddress[verifier].status != Status.ACCEPTED)
            revert NotVerifier();
        _;
    }

	// Ensure that the verifier elligible to (re-/) apply
	modifier elligibleApplicant(
		address verifier
	) {
		if (_verifiersByAddress[verifier].account == address(0) || _verifiersByAddress[verifier].status != Status.REJECTED)
			revert InelligibleApplicant();
		_;
	}

	// Ensure sufficient tokens to submit a proposal
	modifier sufficientTokens() {
		if (_votingToken.balanceOf(msg.sender) < _applicationDeposit)
			revert InsufficientTokens();
		_;
	}

	// Ensure user has not already voted on this application
	modifier notVoted() {
		if (hasVoted[msg.sender][applicationId])
			revert AlreadyVoted();
		_;
	}

	// Ensure application has not already been processed
	modifier applicationPending() {
		if (applications[applicationId].status != Status.REVIEWING)
			revert ApplicationProcessed();
		_;
	}

	// Ensure valid application ID
	modifier applicationValid() {
		if (/* #TODO ? .exists */)
			revert InvalidApplication();
		_;
	}

	// Ensure that the voting period has ended
	modifier votingExpired() {
		if (/* #TODO ? .expires , block.timestamp < _votingPeriod*/)
			revert VotingOpen();
		_;
	}

  	////////////////
    // CONSTRUCTOR
    ////////////////

    constructor(
		address tokenAddress,
		uint256 applicationDeposit,
		uint256 votingPeriod
	) {
        _votingToken = IERC20(tokenAddress);
        _applicationDeposit = applicationDeposit;
        _votingPeriod = votingPeriod;
    }

    function submit(
		string memory data
	)
		external
		sufficientTokens()
	{
		// Handle collateral
        require(_votingToken.transferFrom(msg.sender, address(this), _applicationDeposit), "Token transfer failed");

		// Add application
        Application memory newApplication = Application({
            submitter: msg.sender,
            data: data,
            deposit: _applicationDeposit,
            voteCount: 0,
            status: Status.REVIEWING
        });

		// Add application to array
        uint256 applicationId = applications.length;
        applications.push(newApplication);

		// Emit event
        emit ApplicationCreated(applicationId, msg.sender, data);
    }

    function vote(
		uint256 applicationId,
		uint256 voteCount
	)
		external
		applicationPending(applicationId)
		applicationValid(applicationId)
		notVoted(applicationId)
	{
		// Get application
        Application storage application = applications[applicationId];

		// Add the vote
        hasVoted[msg.sender][applicationId] = true;
        application.voteCount += voteCount;
        balances[msg.sender] += voteCount;

		// Emit event
        emit ApplicationVoted(applicationId, msg.sender, voteCount);
    }

    function processApplication(
		uint256 applicationId
	)
		external
		applicationValid(applicationId)
		applicationPending(applicationId)
		votingExpired()
	{
		// Get application 
        Application storage application = applications[applicationId];

		// Tally vote
        if (application.voteCount > (applications.length / 2)) {
            application.status = Status.ACCEPTED;

			// Emit event
            emit ApplicationAccepted(applicationId);
        } else {
            // If the application is rejected, return the staked deposit to the submitter
            require(_votingToken.transfer(application.submitter, application.deposit), "Token transfer failed");

            application.status = Status.REJECTED;

			// Emit event
            emit ApplicationRejected(applicationId);
        }
    }

	// #TODO CHALLENGE


	// 
}

contract HyperclaimVerifiersCurator is IHyperclaimVerifiersCurator, Ownable {

	enum Status {
		REVIEWING;
		ACCEPTED;
		REJECTED;
	} 

	struct Verifiers {
		address verifier; // Account of verifier
		uint256 applied; // Application date
		uint256 expires; // Expiration date of apply stage
		Status status; 	// Current status of verifier
	}

	// Array of all verifiers applications
	Verifiers[] _verifiers;

	// Mapping from address 
	mapping(address => uint256) _verifiersByAddress;

	// Mapping from status to verifier
	mapping(Status => uint256) _verifiersByStatus;

  	////////////////
    // MODIFIERS
    ////////////////

    // Ensure the subject is a verifier
    modifier onlyVerifier(
		address verifier
	) {
        if (_verifiersByAddress[verifier].status != Status.ACCEPTED)
            revert NotVerifier();
        _;
    }

	// Ensure that the verifier elligible to (re-/) apply
	modifier elligibleApplicant(
		address verifier
	) {
		if (_verifiersByAddress[verifier].account == address(0) || _verifiersByAddress[verifier].status != Status.REJECTED)
			revert InelligibleApplicant();
		_;
	}

    //////////////////////////////////////////////
    // APPLY VERIFIER
    //////////////////////////////////////////////
	
	// Allows a verifier to start an application
    function applyVerifier(
		// #TODO evidence?
	)
		public
	{
		// Collect the payment
		// #TODO
		
        address verifier = _msgSender();

        Verifiers memory verifier = Verifiers(
            verifier,
			applied,
			expires,
			Status.REVIEWING
        );

        // Push to verifiers array
        _verifiers.push(verifier);

		_verifiersByStatus[Status.REVIEWING] = _verifiers.length;
		_verifiersByAddress[verifier] = _verifiers.length;



    }

	

}