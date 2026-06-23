import Foundation

/// Demo 剧情：周日午后的小旅程（3 天 / 3 层深度 / 9 个终点）
///
/// Day 1: 整理桌面（起点）
/// Day 2: 写论文 / 冲咖啡 / 散步（3 条支线）
/// Day 3: 9 个终点叶子（每个 Day 2 任务对应 3 个）
enum TaskLibrary {
    static func demoTree() -> [TaskNode] {
        let submit = UUID(); let library = UUID(); let movie = UUID()
        let read = UUID();   let music = UUID();   let nap = UUID()
        let photo = UUID();  let bench = UUID();   let water = UUID()
        let paper = UUID();  let coffee = UUID();  let walk = UUID()

        return [
            // Day 1
            TaskNode(
                title: "整理桌面",
                subtitle: "一个温暖的开始",
                category: .life,
                day: 1,
                outcomes: [
                    .perfect: .init(type: .perfect,
                                    petDialog: "桌面亮晶晶啦！明天可以开始正经事~",
                                    unlockTaskIDs: [paper],
                                    personalityDelta: .perfect,
                                    xpGain: 15),
                    .partial: .init(type: .partial,
                                    petDialog: "已经整理一半啦，明天先从冲咖啡开始？",
                                    unlockTaskIDs: [coffee],
                                    personalityDelta: .partial,
                                    xpGain: 10),
                    .abandon: .init(type: .abandon,
                                    petDialog: "桌面可以明天再弄，出去走走换换心情？",
                                    unlockTaskIDs: [walk],
                                    personalityDelta: .abandon,
                                    xpGain: 5)
                ]
            ),

            // Day 2 - 完美分支
            TaskNode(
                id: paper,
                title: "写论文",
                subtitle: "把脑子里的想法倒出来",
                category: .study,
                day: 2,
                outcomes: [
                    .perfect: .init(type: .perfect,
                                    petDialog: "好厉害！明天就可以提交了",
                                    unlockTaskIDs: [submit],
                                    personalityDelta: .perfect,
                                    xpGain: 20),
                    .partial: .init(type: .partial,
                                    petDialog: "写出开头就是胜利，明天去图书馆继续？",
                                    unlockTaskIDs: [library],
                                    personalityDelta: .partial,
                                    xpGain: 12),
                    .abandon: .init(type: .abandon,
                                    petDialog: "今天没灵感，明天看个电影充电？",
                                    unlockTaskIDs: [movie],
                                    personalityDelta: .abandon,
                                    xpGain: 5)
                ]
            ),

            // Day 2 - 部分分支
            TaskNode(
                id: coffee,
                title: "冲一杯咖啡",
                subtitle: "5 分钟的小仪式",
                category: .life,
                day: 2,
                outcomes: [
                    .perfect: .init(type: .perfect,
                                    petDialog: "香气飘出来啦！明天可以读那本拖很久的书",
                                    unlockTaskIDs: [read],
                                    personalityDelta: .perfect,
                                    xpGain: 12),
                    .partial: .init(type: .partial,
                                    petDialog: "水刚烧开，明天听张专辑等等？",
                                    unlockTaskIDs: [music],
                                    personalityDelta: .partial,
                                    xpGain: 8),
                    .abandon: .init(type: .abandon,
                                    petDialog: "不想喝咖啡？明天小睡片刻也不错",
                                    unlockTaskIDs: [nap],
                                    personalityDelta: .abandon,
                                    xpGain: 5)
                ]
            ),

            // Day 2 - 放弃分支
            TaskNode(
                id: walk,
                title: "去公园散步",
                subtitle: "让风吹走一些东西",
                category: .health,
                day: 2,
                outcomes: [
                    .perfect: .init(type: .perfect,
                                    petDialog: "阳光真好！明天可以拍点照片记录",
                                    unlockTaskIDs: [photo],
                                    personalityDelta: .perfect,
                                    xpGain: 15),
                    .partial: .init(type: .partial,
                                    petDialog: "走到门口就是开始，明天坐长椅看看？",
                                    unlockTaskIDs: [bench],
                                    personalityDelta: .partial,
                                    xpGain: 10),
                    .abandon: .init(type: .abandon,
                                    petDialog: "不想出门？明天喝杯水就好",
                                    unlockTaskIDs: [water],
                                    personalityDelta: .abandon,
                                    xpGain: 5)
                ]
            ),

            // Day 3 叶子
            leaf(submit,   title: "提交论文",   subtitle: "给自己一个拥抱",     category: .study,  dialog: "完整的旅程走完啦。我为你骄傲。"),
            leaf(library,  title: "去图书馆",   subtitle: "换个环境继续",       category: .study,  dialog: "换个地方，思路也换了一条路。"),
            leaf(movie,    title: "看一部电影", subtitle: "心也需要充电",       category: .life,   dialog: "故事结束了，但你的故事还在继续。"),
            leaf(read,     title: "读一章书",   subtitle: "慢一点也挺好",       category: .study,  dialog: "慢一点的人，看到的风景更多。"),
            leaf(music,    title: "听一张专辑", subtitle: "让旋律带走焦虑",     category: .life,   dialog: "今天的节奏由你定义。"),
            leaf(nap,      title: "小睡片刻",   subtitle: "休息也是有效的选择",  category: .health, dialog: "休息不是放弃，是为了新的可能。"),
            leaf(photo,    title: "拍一张照片", subtitle: "记录此刻的光",       category: .life,   dialog: "这一刻被你留住啦。"),
            leaf(bench,    title: "坐在长椅上", subtitle: "什么都不做也可以",    category: .health, dialog: "什么都不做，也是一种完成。"),
            leaf(water,    title: "喝一杯水",   subtitle: "最小的善意",         category: .health, dialog: "你对自己真好。")
        ]
    }

    private static func leaf(_ id: UUID, title: String, subtitle: String,
                             category: TaskCategory, dialog: String) -> TaskNode {
        TaskNode(
            id: id,
            title: title,
            subtitle: subtitle,
            category: category,
            day: 3,
            outcomes: [
                .perfect: .init(type: .perfect, petDialog: dialog, unlockTaskIDs: [],
                                personalityDelta: .perfect, xpGain: 10),
                .partial: .init(type: .partial, petDialog: dialog, unlockTaskIDs: [],
                                personalityDelta: .partial, xpGain: 8),
                .abandon: .init(type: .abandon, petDialog: dialog, unlockTaskIDs: [],
                                personalityDelta: .abandon, xpGain: 5)
            ]
        )
    }
}
