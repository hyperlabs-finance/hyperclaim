// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import 'openzeppelin-contracts/contracts/access/Ownable.sol';
import '../Interface/IHyperclaimVerifiersCurator.sol';

// #TODO

// Curator manages the addition of verifiers to the verifiers registry via submission and voting
contract TokenCuratedRegistry {

    struct Submission {
        address submitter; // Address of the submission creator
        string data; // Data associated with the submission
        uint256 deposit; // Number of tokens staked as deposit
        uint256 voteCount; // Number of votes received
        bool isAccepted; // Whether the submission is accepted or rejected
    }

    IERC20 public token; // IERC20 token used for voting
    uint256 public submissionDeposit; // Minimum number of tokens required as a deposit for submission
    uint256 public votingPeriod; // Duration of the voting period in seconds

    Submission[] public submissions; // Array of all submissions
    mapping(address => uint256) public balances; // Mapping of token balances for each participant
    mapping(address => mapping(uint256 => bool)) public hasVoted; // Mapping to track whether a participant has voted on a submission

    event SubmissionCreated(uint256 indexed submissionId, address indexed submitter, string data);
    event SubmissionVoted(uint256 indexed submissionId, address indexed voter, uint256 voteCount);
    event SubmissionAccepted(uint256 indexed submissionId);
    event SubmissionRejected(uint256 indexed submissionId);

    constructor(address _tokenAddress, uint256 _submissionDeposit, uint256 _votingPeriod) {
        token = IERC20(_tokenAddress);
        submissionDeposit = _submissionDeposit;
        votingPeriod = _votingPeriod;
    }

    function submit(string memory _data) external {
        require(token.balanceOf(msg.sender) >= submissionDeposit, "Insufficient tokens to submit");
        require(token.transferFrom(msg.sender, address(this), submissionDeposit), "Token transfer failed");

        Submission memory newSubmission = Submission({
            submitter: msg.sender,
            data: _data,
            deposit: submissionDeposit,
            voteCount: 0,
            isAccepted: false
        });
        uint256 submissionId = submissions.length;
        submissions.push(newSubmission);

        emit SubmissionCreated(submissionId, msg.sender, _data);
    }

    function vote(uint256 _submissionId, uint256 _voteCount) external {
        require(_submissionId < submissions.length, "Invalid submission ID");
        require(!hasVoted[msg.sender][_submissionId], "Already voted on this submission");

        Submission storage submission = submissions[_submissionId];
        require(submission.isAccepted == false, "Submission has already been accepted");

        hasVoted[msg.sender][_submissionId] = true;
        submission.voteCount += _voteCount;
        balances[msg.sender] += _voteCount;

        emit SubmissionVoted(_submissionId, msg.sender, _voteCount);
    }

    function processSubmission(uint256 _submissionId) external {
        require(_submissionId < submissions.length, "Invalid submission ID");

        Submission storage submission = submissions[_submissionId];
        require(submission.isAccepted == false, "Submission has already been processed");

        // Check if the voting period has ended
        require(block.timestamp >= votingPeriod, "Voting period has not ended yet");

        if (submission.voteCount > (submissions.length / 2)) {
            submission.isAccepted = true;
            emit SubmissionAccepted(_submissionId);
        } else {
            // If the submission is rejected, return the staked deposit to the submitter
            require(token.transfer(submission.submitter, submission.deposit), "Token transfer failed");
            emit

 SubmissionRejected(_submissionId);
        }
    }
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