<template>
  <div>
    <c-page-label title="标题" icon="cyber-yingyong" document-link="javascript:;">
      <template #tips>提示内容。</template>
    </c-page-label>

    <c-table-wrapper
      rowKey="id"
      ref="tableRef"
      v-model:loading="tableState.loading"
      :columns="tableState.columns"
      :overlayMenu="tableState.overlayMenu"
      @search="methods.searchQuery"
    >
      <template #collapse>
  <#list columnList as column>
        <!-- ${column.columnComment}搜索 -->
        <a-input
          v-model:value="queryState.${column.columnName}"
          placeholder="请输入${column.columnComment}搜索..."
          style="width: 256px"
          @keydown.enter="methods.searchQuery()"
        >
          <template #suffix><c-icon icon="cyber-sousuo" size="16" color="#BDBDBD" /></template>
        </a-input>
  </#list>
      </template>
      <template #right>
        <a-button type="primary" @click="methods.showModify()">新建</a-button>
      </template>
    </c-table-wrapper>

    <Modify ref="modifyRef" @ok="methods.searchQuery()"></Modify>
  </div>
</template>

<script setup>
import { deleteConfrim } from '@/api';
import Modify from './modules/Modify.vue';
import { changeHistoryState, initHistoryState } from 'cyber-web-ui';
const tableRef = ref(); // 表格ref
const modifyRef = ref(); // 弹窗ref
// 表格请求参数
const queryState = reactive({
  ...initHistoryState({
<#list columnList as column>
    ${column.columnName}: undefined,
</#list>
  }),
});
// 表格信息
const tableState = reactive({
  loading: false,
  columns: [
<#list columnList as column>
    { title: '${column.columnComment}', dataIndex: "${column.columnName}" },
</#list>
  ],
  overlayMenu: [
    {
      label: "编辑",
      handler: (record) => methods.showModify(record),
    },
    {
      label: "删除",
      handler: (record) => methods.delete(record),
    },
  ],
});

const methods = {
  // 搜索表格
  searchQuery() {
    changeHistoryState(queryState);
    unref(tableRef).searchQuery({
      url: '${classname}/search',
      method: 'get',
      params: queryState,
    });
  },
  // 显示弹窗
  showModify(record) {
    unref(modifyRef).showModal(record);
  },
  // 删除
  delete(record) {
    deleteConfrim({
      content: `是否确认删除“${'$' + '{record.name}'}（${'$' + '{record.code}'}）”？`,
      value: record.code,
    }, {
      url: '${classname}',
      method: 'delete',
      params: {
        id: record.id,
      }
    }).then(() => {
      methods.searchQuery();
    });
  },
};

onMounted(() => {
  methods.searchQuery();
});
</script>

<style lang="less" scoped>
</style>
