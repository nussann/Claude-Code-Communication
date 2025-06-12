#!/bin/bash
# Multi-Agent Role Management Helper Script

# 新しい役割を作成
create_role() {
    if [ $# -ne 2 ]; then
        echo "Usage: $0 create <role_name> <role_description>"
        exit 1
    fi

    role_name=$1
    role_description=$2

    mkdir -p "$role_name"
    cat > "$role_name/CLAUDE.md" << EOF
# ${role_description} Role Instructions

You are acting as ${role_description}.
# Add specific instructions here
EOF

    echo "Role '$role_name' created successfully"
}

# プロジェクトをリンク
link_project() {
    if [ $# -ne 2 ]; then
        echo "Usage: $0 link <role_name> <project_name>"
        exit 1
    fi

    role_name=$1
    project_name=$2

    if [ ! -d "$role_name" ]; then
        echo "Error: Role '$role_name' does not exist"
        exit 1
    fi

    if [ ! -d "shared-projects/$project_name" ]; then
        echo "Error: Project '$project_name' does not exist"
        exit 1
    fi

    cd "$role_name"
    ln -s "../shared-projects/$project_name" "$project_name"
    cd ..

    echo "Project '$project_name' linked to role '$role_name' successfully"
}

# 新しいプロジェクトを作成
create_project() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 create_project <project_name>"
        exit 1
    fi

    project_name=$1
    mkdir -p "shared-projects/$project_name"
    echo "Project '$project_name' created successfully"
}

# 新しいプロジェクトを作成して全役割に自動リンク
create_new_project() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 -n <project_name>"
        echo "Examples:"
        echo "  $0 -n my-project"
        echo "  $0 -n \"my project with spaces\""
        exit 1
    fi

    # 複数引数を結合（スペースを含むプロジェクト名に対応）
    project_name="$*"
    
    echo "🚀 Creating new project: $project_name"
    echo "==========================================="
    
    # 1. プロジェクト作成
    echo "📁 Creating project directory..."
    mkdir -p "shared-projects/$project_name"
    echo "✅ Project 'shared-projects/$project_name' created successfully"
    
    # 2. 各役割への自動リンク
    echo ""
    echo "🔗 Linking project to all roles..."
    
    # 役割ディレクトリが存在する場合のみリンク
    for role in GM TL ST; do
        if [ -d "$role" ]; then
            # project サブディレクトリを作成
            mkdir -p "$role/project"
            cd "$role/project"
            if [ ! -L "$project_name" ]; then
                ln -s "../../shared-projects/$project_name" "$project_name"
                echo "✅ $role/project/$project_name -> ../../shared-projects/$project_name"
            else
                echo "⚠️  $role/project/$project_name already exists (skipped)"
            fi
            cd ../..
        else
            echo "⚠️  Role directory '$role' not found (skipped)"
        fi
    done
    
    echo ""
    echo "🎉 Project setup completed!"
    echo "📋 Summary:"
    echo "   - Project: shared-projects/$project_name"
    echo "   - Linked to: GM, TL, ST"
    echo ""
    echo "💡 Next steps:"
    echo "   cd GM/project/$project_name   # or TL/project/$project_name or ST/project/$project_name"
    echo "   claude                        # Start working on the project"
}

# コマンドの実行
case "$1" in
    create)
        create_role "$2" "$3"
        ;;
    link)
        link_project "$2" "$3"
        ;;
    create_project)
        create_project "$2"
        ;;
    -n)
        shift  # -nオプションを除去
        create_new_project "$@"  # 残りの全引数を渡す
        ;;
    *)
        echo "Usage:"
        echo "  $0 create <role_name> <role_description>"
        echo "  $0 link <role_name> <project_name>"
        echo "  $0 create_project <project_name>"
        echo "  $0 -n <project_name>              # Create project and auto-link to all roles"
        exit 1
        ;;
esac