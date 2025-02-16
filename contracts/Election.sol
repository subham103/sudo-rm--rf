pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import './Ownable.sol';

contract Election is Ownable{

  event VoterCreated(uint256 _id, uint256 _voterId);
  event CandidateRegistered(uint256 _id);
  event ConstituencyRegistered(uint256 _id);

  struct Vote {
    bytes32 _voteId;
    uint256 _votedId;
    uint64 _voteTime;
  }

  struct Voter {
    uint256 _id;
    uint256 _constituencyId;
    bool _hasVoted;
    Vote _vote;
  }

  struct Candidate {
    uint256 _id;
  }

  struct Constituency {
    uint256 _id;
    uint256 _startTime;
    uint256 _duration;
  }

  Vote InitialVoteState = Vote(0, 0, 0);
  bool ResultsDeclared = false;

  mapping(uint256 => Voter) internal idToVoter;
  mapping(uint256 => Candidate) internal idToCandidate;
  mapping(uint256 => Constituency) internal idToConstituency;
  mapping(bytes32 => uint256) internal voteToCandidate;
  mapping(uint256 => uint256) internal candidateToConstituency;
  mapping(uint256 => uint256) internal constituencyCandidateCount;
  mapping(uint256 => uint256) internal candidateVoteCount;

  Voter[] public voters;
  Candidate[] public candidates;
  Constituency[] public constituencies;
  uint256[] public admins;

  modifier onlyUser(uint256 _id) {
    require(idToVoter[_id]._id != 0);
    _;
  }

  modifier onlyAdmin(uint256 _id) {
    for(uint i = 0; i < admins.length; i++) {
      if(admins[i] == _id) {
        _;
        }
      else {
        continue;
      }
    }
  }

  modifier declaredResults() {
    require(ResultsDeclared == true);
    _;
  }

  function createVoter(uint256 _id, uint256 _constituencyId) internal {
    uint id = voters.push(Voter(_id, _constituencyId, false, InitialVoteState)) - 1;
    idToVoter[_id] = voters[id];
    emit VoterCreated(_id, _constituencyId);
  }

  function registerCandidate(uint256 _id, uint256 _adminId) external onlyAdmin(_adminId) {
    uint id = candidates.push(Candidate(_id)) - 1;
    idToCandidate[_id] = candidates[id];
    emit CandidateRegistered(_id);
  }

  function registerConstituency(uint256 _id, uint256 _adminId) external onlyAdmin(_adminId) {
    uint id = constituencies.push(Constituency(_id, 0, 0)) - 1;
    idToConstituency[_id] = constituencies[id];
    emit ConstituencyRegistered(_id);
  }

  function registerAdmin(uint256 _id) external onlyOwner {
    admins.push(_id);
  }

}