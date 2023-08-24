// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract TodoList {
    enum TodoStatus {
        Pending,
        InProgress,
        Completed
    }

    struct TodoItem {
        string content;
        bool is_deleted;
        uint256 createdAt;
        TodoStatus status;
        address payer;
        uint256 amount;
    }
    
    struct User {
        string username;
        string password;
        mapping(uint256 => TodoItem[]) todoLists;
        uint256 todoListCount; // Track the number of todo lists
    }
    
    mapping(address => User) private users;
    
    function createUser(string memory _username, string memory _password) public {
        require(bytes(_username).length > 0, "Username must not be empty");
        require(bytes(_password).length > 0, "Password must not be empty");
        require(bytes(users[msg.sender].username).length == 0, "User already exists");
        
        users[msg.sender].username = _username;
        users[msg.sender].password = _password;
    }
    
    function createTodoList(uint256 _listId, string memory _todoList) public payable {
        require(bytes(users[msg.sender].username).length > 0, "User does not exist");
        require(msg.value > 0, "Please send some ether to create a todo list");
        
        TodoItem[] storage items = users[msg.sender].todoLists[_listId];
        items.push(TodoItem(_todoList, false, block.timestamp, TodoStatus.Pending, msg.sender, msg.value));
        
        if (items.length == 1) {
            users[msg.sender].todoListCount++;
        }
    }
    
    function markTodoItemDeleted(uint256 _listId, uint256 _itemId) public returns (uint256) {
        require(bytes(users[msg.sender].username).length > 0, "User does not exist");
        require(_itemId < users[msg.sender].todoLists[_listId].length, "Invalid item ID");
        require(!users[msg.sender].todoLists[_listId][_itemId].is_deleted, "Item already deleted");
        
        users[msg.sender].todoLists[_listId][_itemId].is_deleted = true;
        uint256 amount = users[msg.sender].todoLists[_listId][_itemId].amount;
        users[msg.sender].todoLists[_listId][_itemId].amount = 0;
        
        return amount;
    }
    
    function updateTodoItem(uint256 _listId, uint256 _itemId, string memory _newContent) public {
        require(bytes(users[msg.sender].username).length > 0, "User does not exist");
        require(_itemId < users[msg.sender].todoLists[_listId].length, "Invalid item ID");
        
        users[msg.sender].todoLists[_listId][_itemId].content = _newContent;
    }
    
    function deleteTodoItem(uint256 _listId, uint256 _itemId) public returns (uint256) {
        require(bytes(users[msg.sender].username).length > 0, "User does not exist");
        require(_itemId < users[msg.sender].todoLists[_listId].length, "Invalid item ID");
        require(!users[msg.sender].todoLists[_listId][_itemId].is_deleted, "Item already deleted");
        
        uint256 amount = markTodoItemDeleted(_listId, _itemId);
        
        // Remove the item from the array by shifting elements
        TodoItem[] storage items = users[msg.sender].todoLists[_listId];
        for (uint256 i = _itemId; i < items.length - 1; i++) {
            items[i] = items[i + 1];
        }
        items.pop();
        
        if (items.length == 0) {
            users[msg.sender].todoListCount--;
        }
        
        return amount;
    }
    
    function getTodoList(uint256 _listId) public view returns (TodoItem[] memory) {
        require(bytes(users[msg.sender].username).length > 0, "User does not exist");
        
        return users[msg.sender].todoLists[_listId];
    }
    
    function getTodoListCount() public view returns (uint256) {
        require(bytes(users[msg.sender].username).length > 0, "User does not exist");
        
        return users[msg.sender].todoListCount;
    }
}
