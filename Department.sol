pragma solidity >=0.4.17 <0.7.0;
contract Department{
    
    struct Employee{
        string employeeName;
        uint128 order;
    }
    
    uint128 departmentId;
    uint128 goal;
    uint32 startDate;
    uint32 endDate;
    mapping (uint128 => Employee) public employees;
    uint128[] public departmentEmployees;
    address public owner;
    uint128 minimumOrder;
    uint128 public totalOrder;
    
    //This will call when we deploy contract for the first time
    constructor(uint128 _departmentId, uint128 _expectedOrder, uint32 _startDate, uint32 _endDate) public {
        owner = msg.sender;
        minimumOrder = 1;
        totalOrder = 0;
        departmentId = _departmentId;
        goal = _expectedOrder;
        startDate = _startDate;
        endDate = _endDate;
    }
    
    //This will tackle order history of all the employees
    event logEmployeeData(uint256 _employeeId, string _name, uint128 _order, uint256 _time);
    
    //It will restrict access of the contract to owner only
    modifier restricted() {
        require(msg.sender == owner);
        _;
    }
    
    //It will not allow to update data after endDate of department
    modifier beforeEndDate() {
        require(now < endDate);
        _;
    }
    
    //This will add new employees data on the block chain
    function addEmployee(uint128 _employeeId, string memory _name, uint128 _order) public restricted beforeEndDate {
        require(_order >= minimumOrder);
        Employee storage employee = employees[_employeeId];
        employee.employeeName = _name;
        employee.order = _order;
        totalOrder = totalOrder + _order;
        departmentEmployees.push(_employeeId);
        emit logEmployeeData(_employeeId, _name, _order, now);
    }
    
    //This will update order of existing employees on the block chain
    function updateEmployeeOrder(uint128 _employeeId,  uint128 _order) public restricted beforeEndDate {
        require(_order >= minimumOrder);
        employees[_employeeId].order = employees[_employeeId].order + _order;
        totalOrder = totalOrder + _order;
        emit logEmployeeData(_employeeId, employees[_employeeId].employeeName, _order, now);
    }
    
    //This will change end date with new date
    function extendEndDate(uint32 _newEndDate) public restricted beforeEndDate {
        endDate = _newEndDate;
    }
    
    //This will return all the employee ids
    function getAllEmployees() public view returns (uint128[] memory) {
        return departmentEmployees;
    }
    
     //This will return true if goal achieved
    function isGoalAchieved() public view returns (bool) {
        if(totalOrder>= goal) return true;
        else return false;
    }
    
    //This will return department data
    function departmentData() public view returns(uint128 , uint128 , uint32 , uint32 ) {
        return(departmentId, goal, startDate, endDate);
    }
}   