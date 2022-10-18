import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Array "mo:base/Array";

module {

  public func hasPrincipal(
      principal : Principal, 
      principals : [Principal]
  ) : Bool {
      func isMatch(admin : Principal) : Bool {
      Principal.equal(admin, principal) 
      };
      Option.isSome(Array.find(principals, isMatch))
  };

  public type AdminStatus = {
    #Enabled;
    #Disabled;
  };
  public type AdminEntry = {
    principalId : Text;
    tag : Text;
    status : AdminStatus;
  };
  public type AdminRoles = {
    #Owner;
    #Admin;
    #Controller : [Principal];
  };
  
  public type AccessCheck = {
    #Authorized;
    #Unauthorized;
  };
  public type Error = {
    #Unauthorized;
    #Other: Text;
  };
  public type ResponseAdminCheck<T> = Result.Result<T, Error>;

};
