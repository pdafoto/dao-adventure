import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export type CreateProposalErr = { 'NotDAOMember' : null } |
  { 'NotImplemented' : null } |
  { 'NotEnoughTokens' : null };
export type CreateProposalOk = bigint;
export interface DAO {
  'addGoal' : ActorMethod<[string], undefined>,
  'addMember' : ActorMethod<[Member], Result>,
  'balanceOf' : ActorMethod<[Account], bigint>,
  'createProposal' : ActorMethod<[string], createProposalResult>,
  'getAllMembers' : ActorMethod<[], Array<Member>>,
  'getGoals' : ActorMethod<[], Array<string>>,
  'getManifesto' : ActorMethod<[], string>,
  'getMember' : ActorMethod<[Principal], Result_1>,
  'getName' : ActorMethod<[], string>,
  'getProposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'mint' : ActorMethod<[Principal, bigint], undefined>,
  'numberOfMembers' : ActorMethod<[], bigint>,
  'removeMember' : ActorMethod<[], Result>,
  'setManifesto' : ActorMethod<[string], undefined>,
  'tokenName' : ActorMethod<[], string>,
  'tokenSymbol' : ActorMethod<[], string>,
  'totalSupply' : ActorMethod<[], bigint>,
  'transfer' : ActorMethod<[Account, Account, bigint], Result>,
  'updateMember' : ActorMethod<[Member], Result>,
  'vote' : ActorMethod<[bigint, boolean], voteResult>,
  'whoami' : ActorMethod<[], Principal>,
}
export type HeaderField = [string, string];
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Uint8Array | number[],
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Uint8Array | number[],
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [StreamingStrategy],
  'status_code' : number,
}
export interface Member { 'age' : bigint, 'name' : string }
export interface Proposal {
  'id' : bigint,
  'status' : Status,
  'votes' : bigint,
  'voters' : Array<Principal>,
  'manifest' : string,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : Member } |
  { 'err' : string };
export type Status = { 'Open' : null } |
  { 'Rejected' : null } |
  { 'Accepted' : null };
export type StreamingCallback = ActorMethod<
  [StreamingCallbackToken],
  StreamingCallbackResponse
>;
export interface StreamingCallbackResponse {
  'token' : [] | [StreamingCallbackToken],
  'body' : Uint8Array | number[],
}
export interface StreamingCallbackToken {
  'key' : string,
  'index' : bigint,
  'content_encoding' : string,
}
export type StreamingStrategy = {
    'Callback' : {
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }
  };
export type Subaccount = Uint8Array | number[];
export type VoteErr = { 'AlreadyVoted' : null } |
  { 'ProposalEnded' : null } |
  { 'ProposalNotFound' : null } |
  { 'NotImplemented' : null };
export type VoteOk = { 'ProposalOpen' : null } |
  { 'ProposalRefused' : null } |
  { 'ProposalAccepted' : null };
export type createProposalResult = { 'ok' : CreateProposalOk } |
  { 'err' : CreateProposalErr };
export type voteResult = { 'ok' : VoteOk } |
  { 'err' : VoteErr };
export interface _SERVICE extends DAO {}
