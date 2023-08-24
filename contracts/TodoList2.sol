// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList2 {
    enum TaskStatus {InProgress, Pending, Completed}

    struct Task {
        uint256 index;
        string content;
        TaskStatus status;
        uint256 amount;
        address sender;
        string description;
        string image;
    }

    struct User {
        string username;
        string password;
        Task[] tasks;
    }

    mapping(string => User) private users;

    event UserCreated(string username);
    event TaskCreated(string username, uint256 index, uint256 amount, address sender, string description, string image);
    event TaskDeleted(string username, uint256 index, uint256 amount, address sender);
    event TaskUpdated(string username, uint256 index, string content, TaskStatus status, string description, string image);

    function createUser(string memory _username, string memory _password) public {
        require(bytes(users[_username].username).length == 0, "Username already exists");

        User storage user = users[_username];
        user.username = _username;
        user.password = _password;

        emit UserCreated(_username);
    }

    function login(string memory _username, string memory _password) public view returns (bool) {
        User storage user = users[_username];
        require(bytes(user.username).length != 0, "User not found");

        return (keccak256(bytes(user.password)) == keccak256(bytes(_password)));
    }


    function createTask(
        string memory _username,
        string memory _content,
        string memory _description,
        string memory _image
    )
        public
        payable
    {
        User storage user = users[_username];
        require(bytes(user.username).length != 0, "User not found");
        require(msg.value > 0, "Please send some ether to create a todo list");
        uint256 newIndex = user.tasks.length;

        Task memory newTask = Task({
            index: newIndex,
            content: _content,
            status: TaskStatus.InProgress,
            amount: msg.value,
            sender: msg.sender,
            description: _description,
            image: _image
        });
        user.tasks.push(newTask);

        emit TaskCreated(_username, newIndex, msg.value, msg.sender, _description, _image);
    }

    function updateTask(
        string memory _username,
        uint256 _index,
        string memory _content,
        TaskStatus _status,
        string memory _description,
        string memory _image
    )
        public
    {
        User storage user = users[_username];
        require(bytes(user.username).length != 0, "User not found");
        require(_index < user.tasks.length, "Invalid task index");

        Task storage task = user.tasks[_index];
        task.content = _content;
        task.status = _status;
        task.description = _description;
        task.image = _image;

        emit TaskUpdated(_username, _index, _content, _status, _description, _image);
    }

    function deleteTask(string memory _username, uint256 _index) public {
        User storage user = users[_username];
        require(bytes(user.username).length != 0, "User not found");
        require(_index < user.tasks.length, "Invalid task index");

        Task storage task = user.tasks[_index];

        // Transfer the task amount back to the original sender
        payable(task.sender).transfer(task.amount);

        // Swap the task to be deleted with the last task in the array
        uint256 lastIndex = user.tasks.length - 1;
        user.tasks[_index] = user.tasks[lastIndex];

        // Update the index of the swapped task
        user.tasks[_index].index = _index;

        // Delete the last task in the array
        user.tasks.pop();

        emit TaskDeleted(_username, _index, task.amount, task.sender);
    }

    function getTaskByIndex(string memory _username, uint256 _index) public view returns (Task memory) {
        User storage user = users[_username];
        require(bytes(user.username).length != 0, "User not found");
        require(_index < user.tasks.length, "Invalid task index");

        Task storage task = user.tasks[_index];
        return task;
    }

    function getUserTasks(string memory _username) public view returns (Task[] memory) {
        User storage user = users[_username];
        require(bytes(user.username).length != 0, "User not found");
        
        return user.tasks;
    }

    function getContractInfo() public view returns (address, uint256) {
        return (address(this), address(this).balance);
    }
   
}
