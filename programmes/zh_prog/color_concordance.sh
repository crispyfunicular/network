#!/bin/bash

# ================= 配置区域 =================
# 1. 统计结果文件 (PALS partition 输出的 TSV)
# 确保你已经用 tr 把空格转成了 tab，如果还没转，脚本下面会自动处理
STATS_FILE="../../statistique/specificity_results.tsv"

# 2. 停用词表 (一行一个词，比如：的、了、是...)
STOP_FILE="../../statistique/stopwords.txt"

# 3. HTML 文件所在的目录 (假设就在当前目录，或者 ../../concordances/zh/)
# 如果 html 文件在上一级目录，请改成 HTML_DIR="../../concordances/zh/"
HTML_DIR="./"

# 4. 文件名后缀 (用户说是 1-concord.html)
HTML_SUFFIX="-concord.html"
# ===========================================

echo "========================================"
echo "开始给 Concordancier 上色 (Coloration)"
echo "统计表: $STATS_FILE"
echo "停用词: $STOP_FILE"
echo "========================================"

# 循环检测 1 到 50 (预设一个足够大的范围，或者根据你的实际文件数改)
# 只要文件存在就会处理
for (( ID=1; ID<=50; ID++ ))
do
    # 拼凑文件名：例如 1-concord.html
    TARGET_HTML="${HTML_DIR}${ID}${HTML_SUFFIX}"

    # 1. 检查文件是否存在，不存在就跳过（比如只有10个文件，循环到11就会自动停）
    if [ ! -f "$TARGET_HTML" ]; then
        # 如果连第1个都找不到，可能是路径错了，提示一下
        if [ $ID -eq 1 ]; then
            echo "错误：找不到文件 $TARGET_HTML，请检查 HTML_DIR 配置。"
            exit 1
        fi
        # 找不到文件通常意味着处理完了
        continue
    fi

    echo "正在处理文件: $TARGET_HTML (ID: $ID)..."

    # 2. 计算 Specificity 分数在第几列
    # PALS 表格结构: Col1=Word, Col2=Total, Col3=Cnt1, Col4=Specif1, Col5=Cnt2, Col6=Specif2...
    # 公式: 目标列 = 2 + (ID * 2)
    # 例子: ID=1 -> Col 4; ID=2 -> Col 6
    COL_NUM=$(( 2 + ID * 2 ))

    # 3. 提取该文件分数最高的 Top 5 实词
    # 逻辑：
    # awk: 提取第1列(词)和目标列(分数)，跳过第一行表头(NR>1)
    # sort: 按分数(第2列)数字逆序排序
    # grep: 排除停用词
    # head: 取前5个
    # awk: 只保留单词

    TOP_WORDS=$(awk -v c="$COL_NUM" 'NR>1 {print $1, $c}' "$STATS_FILE" \
                | sort -k2,2nr \
                | grep -v -f "$STOP_FILE" \
                | head -n 5 \
                | awk '{print $1}')

    # 如果没提取到词（可能列数算错了或者文件为空），提示一下
    if [ -z "$TOP_WORDS" ]; then
        echo "  ⚠️ 警告: 没有提取到关键词，请检查 TSV 文件格式或列号。"
        continue
    fi

    echo "  -> 🎯 本篇特异词 (Top 5): $(echo $TOP_WORDS | tr '\n' ' ')"

    # 4. 替换 HTML 内容 (上色)
    # 使用 sed 批量替换。将 单词 替换为 <span ...>单词</span>
    # 注意：这里使用 class="has-text-danger" 是 Bulma 框架的红色，你可以改成 style="color:red"

    for WORD in $TOP_WORDS
    do
        # 这里的 sed 也就是把 "网络" 变成 "<span class='...'>网络</span>"
        # 只要这个词出现在表格里（无论是在左边 Context 还是右边），都会变红

        # Mac系统和Linux系统的sed -i 写法不同，为了通用，我们用临时文件法
        sed "s/$WORD/<span class=\"has-text-danger has-text-weight-bold\">$WORD<\/span>/g" "$TARGET_HTML" > "${TARGET_HTML}.tmp" && mv "${TARGET_HTML}.tmp" "$TARGET_HTML"
    done

    echo "  -> ✅ 上色完成"

done

echo "========================================"
echo "所有处理结束！请打开 HTML 文件查看效果。"
