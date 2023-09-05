// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    enum StatesStages {PendienteInicio, EnProceso, Finalizado}
    struct Stage {
        string title;
        string description;
        uint256 deadline;
        bool hasMilestone;
        string milestone; //PDF {format:'PDF'}
        StatesStages estado;
    }
    struct CampaignWithRoadmap {
        address owner;
        string title;
        string video;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        uint256 amountStages;
        string image;
        address[] donators;
        uint256[] donations;
        mapping(uint256=>Stage) stages;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => CampaignWithRoadmap) public campaignsWithRoadmap;

    uint256 public numberOfCampaigns = 0;
    uint256 public numberOfCampaignsWithRoadmap = 0;

    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent,) = payable(campaign.owner).call{value: amount}("");

        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    function createCampaignWithRoadmap(address _owner, string memory _title, string memory _video, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns (uint256) {
        CampaignWithRoadmap storage campaignWithRoadmap = campaignsWithRoadmap[numberOfCampaignsWithRoadmap];

        require(campaignWithRoadmap.deadline < block.timestamp, "The deadline should be a date in the future.");

        campaignWithRoadmap.owner = _owner;
        campaignWithRoadmap.title = _title;
        campaignWithRoadmap.description = _description;
        campaignWithRoadmap.target = _target;
        campaignWithRoadmap.deadline = _deadline;
        campaignWithRoadmap.amountCollected = 0;
        campaignWithRoadmap.amountStages = 0;
        campaignWithRoadmap.image = _image;
        campaignWithRoadmap.video = _video;


        numberOfCampaignsWithRoadmap++;

        return numberOfCampaignsWithRoadmap - 1;
    }

    function donateToCampaignWithRoadmap(uint256 _id) public payable {
        uint256 amount = msg.value;

        CampaignWithRoadmap storage campaignWithRoadmap = campaignsWithRoadmap[_id];

        campaignWithRoadmap.donators.push(msg.sender);
        campaignWithRoadmap.donations.push(amount);

        (bool sent,) = payable(campaignWithRoadmap.owner).call{value: amount}("");

        if(sent) {
            campaignWithRoadmap.amountCollected = campaignWithRoadmap.amountCollected + amount;
        }
    }

    function getDonatorsWithRoadmap(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaignsWithRoadmap[_id].donators, campaignsWithRoadmap[_id].donations);
    }

    function getCampaignsWithRoadmap() public view returns (CampaignWithRoadmap[] memory) {
        CampaignWithRoadmap[] memory allCampaignsWithRoadmap = new CampaignWithRoadmap[](numberOfCampaignsWithRoadmap);

        for(uint i = 0; i < numberOfCampaignsWithRoadmap; i++) {
            CampaignWithRoadmap storage item = campaignsWithRoadmap[i];

            allCampaignsWithRoadmap[i] = item;
        }

        return allCampaignsWithRoadmap;
    }

    function createStage(uint256 _id, string memory _title, string memory _description, uint256 _deadline, bool _hasMilestone, string memory _milestone) public {
        require(_id < numberOfCampaignsWithRoadmap, "La campaña no existe.");
        require(_deadline > block.timestamp, "La fecha límite debe ser en el futuro.");

        CampaignWithRoadmap storage campaign = campaignsWithRoadmap[_id];
        Stage storage stage = campaign.stages[campaign.amountStages];

        stage.title = _title;
        stage.description = _description;
        stage.deadline = _deadline;
        stage.hasMilestone = _hasMilestone;
        stage.milestone = _milestone;
        stage.estado = StatesStages.PendienteInicio;
        campaign.amountStages++;
    }

    function updateStage(uint256 _campaignId, uint256 _stageId, string memory _title, string memory _description, uint256 _deadline, bool _hasMilestone, string memory _milestone, StatesStages _estado) public {
        require(_campaignId < numberOfCampaignsWithRoadmap, "La campaña no existe.");
        require(_stageId < campaignsWithRoadmap[_campaignId].amountStages, "La etapa no existe.");
        require(_deadline > block.timestamp, "La fecha límite debe ser en el futuro.");

        CampaignWithRoadmap storage campaign = campaignsWithRoadmap[_campaignId];
        Stage storage stage = campaign.stages[_stageId];

        stage.title = _title;
        stage.description = _description;
        stage.deadline = _deadline;
        stage.hasMilestone = _hasMilestone;
        stage.milestone = _milestone;
        stage.estado = _estado;
    }

}