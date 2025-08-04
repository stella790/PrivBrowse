import { describe, it, expect, beforeEach } from "vitest"

type Campaign = {
  creator: string
  budget: bigint
  rewardPerUser: bigint
  participants: number
  settled: boolean
}

const admin = "ST1ADMIN..."
let contract: any

beforeEach(() => {
  contract = {
    admin,
    paused: false,
    nextCampaignId: 1,
    optedIn: new Set<string>(),
    rewardBalance: new Map<string, bigint>(),
    claimedReward: new Map<string, Map<number, boolean>>(),
    campaigns: new Map<number, Campaign>(),

    isAdmin: (caller: string) => caller === contract.admin,

    optIn(caller: string) {
      if (contract.paused) return { error: 101 }
      if (contract.optedIn.has(caller)) return { error: 102 }
      contract.optedIn.add(caller)
      return { value: true }
    },

    createCampaign(caller: string, budget: bigint, rewardPerUser: bigint) {
      if (contract.paused) return { error: 101 }
      if (budget <= 0n || rewardPerUser <= 0n || rewardPerUser > budget) return { error: 106 }
      const id = contract.nextCampaignId++
      contract.campaigns.set(id, {
        creator: caller,
        budget,
        rewardPerUser,
        participants: 0,
        settled: false
      })
      return { value: id }
    },

    participate(caller: string, campaignId: number) {
      if (contract.paused) return { error: 101 }
      if (!contract.optedIn.has(caller)) return { error: 103 }
      const campaign = contract.campaigns.get(campaignId)
      if (!campaign || campaign.settled) return { error: 105 }

      const userClaims = contract.claimedReward.get(caller) || new Map()
      if (userClaims.get(campaignId)) return { error: 107 }

      userClaims.set(campaignId, true)
      contract.claimedReward.set(caller, userClaims)

      const reward = contract.rewardBalance.get(caller) || 0n
      contract.rewardBalance.set(caller, reward + campaign.rewardPerUser)

      campaign.budget -= campaign.rewardPerUser
      campaign.participants += 1
      contract.campaigns.set(campaignId, campaign)

      return { value: reward + campaign.rewardPerUser }
    },

    claimReward(caller: string) {
      if (contract.paused) return { error: 101 }
      const amount = contract.rewardBalance.get(caller) || 0n
      if (amount <= 0n) return { error: 104 }
      contract.rewardBalance.set(caller, 0n)
      return { value: amount }
    }
  }
})

describe("Ad Reward Contract", () => {
  const user = "ST2USER..."
  const other = "ST3OTHER..."

  it("should allow opt-in", () => {
    const res = contract.optIn(user)
    expect(res).toEqual({ value: true })
  })

  it("should allow campaign creation", () => {
    const res = contract.createCampaign(admin, 1000n, 100n)
    expect(res).toHaveProperty("value")
  })

  it("should allow user to participate and earn reward", () => {
    contract.optIn(user)
    const { value: campaignId } = contract.createCampaign(admin, 1000n, 100n)
    const res = contract.participate(user, campaignId)
    expect(res).toEqual({ value: 100n })
  })

  it("should prevent duplicate participation", () => {
    contract.optIn(user)
    const { value: campaignId } = contract.createCampaign(admin, 1000n, 100n)
    contract.participate(user, campaignId)
    const res = contract.participate(user, campaignId)
    expect(res).toEqual({ error: 107 })
  })

  it("should allow reward claim", () => {
    contract.optIn(user)
    const { value: campaignId } = contract.createCampaign(admin, 1000n, 100n)
    contract.participate(user, campaignId)
    const res = contract.claimReward(user)
    expect(res).toEqual({ value: 100n })
  })
})
