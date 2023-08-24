// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract MessagingApp {
    struct Message {
        address sender;
        address receiver;
        string content;
        string imageUrl;
        uint256 timestamp;
    }

    mapping(address => mapping(address => Message[])) private conversations;
    mapping(address => address[]) private receivers;

    event MessageSent(
        address indexed sender,
        address indexed receiver,
        string content,
        string imageUrl,
        uint256 timestamp
    );

    function sendMessage(address _sender, address _receiver, string memory _content, string memory _imageUrl) public {
        Message memory newMessage = Message({
            sender: _sender,
            receiver: _receiver,
            content: _content,
            imageUrl: _imageUrl,
            timestamp: block.timestamp
        });

        conversations[_sender][_receiver].push(newMessage);

        if (!receiverExists(_sender, _receiver)) {
            receivers[_sender].push(_receiver);
        }

        emit MessageSent(_sender, _receiver, _content, _imageUrl, block.timestamp);
    }

    function getConversation(address _sender, address _receiver) public view returns (Message[] memory) {
        return conversations[_sender][_receiver];
    }

    function getAllReceivers(address _sender) public view returns (address[] memory) {
        return receivers[_sender];
    }

    function receiverExists(address _sender, address _receiver) private view returns (bool) {
        address[] storage senderReceivers = receivers[_sender];
        for (uint256 i = 0; i < senderReceivers.length; i++) {
            if (senderReceivers[i] == _receiver) {
                return true;
            }
        }
        return false;
    }
}
