<template>
  <g-page-label title="标题" icon="icon-rongqi">
    <template #tips>提示内容。</template>
  </g-page-label>

  <g-page-body>
    <template #header>
      <g-params :loading="tableState.loading" @search="methods.searchQuery()">
        <#list columnList as column>
          <!-- ${column.columnComment}搜索 -->
          <a-input
            v-model:value="queryParams.${column.columnName}"
            placeholder="输入${column.columnComment}搜索..."
            @keydown.enter="methods.searchQuery()"
          ></a-input>
        </#list>
        <template #right>
          <a-button type="primary" @click="methods.showModify()">创建</a-button>
        </template>
      </g-params>
    </template>

    <g-table
      ref="tableRef"
      rowKey="id"
      v-model:loading="tableState.loading"
      :columns="tableState.columns"
      :overlayMenu="tableState.overlayMenu"
    ></g-table>
  </g-page-body>

  <Modify ref="modifyRef" @ok="methods.searchQuery()"></Modify>
</template>

<script setup>
import axios from '@/api';
import { message } from 'ant-design-vue';
import { changeHistoryState, initHistoryState } from "@/utils/dispose";
import Modify from './modules/Modify.vue';
import GModal from '@/components/global/modal/g-modal.jsx';

const tableRef = ref(); // 表格ref
const modifyRef = ref(); // 弹窗ref
// 表格请求参数
const queryParams = reactive({
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
  async searchQuery() {
    changeHistoryState(queryParams);
    nextTick(() => {
      unref(tableRef).searchQuery({
        url: '/${classname}/search',
        method: 'get',
        data: queryParams,
      });
    });
  },
  // 显示弹窗
  showModify(record) {
    unref(modifyRef).showModal(record);
  },
  delete(record) {
    GModal.confirm({
      title: `删除`,
      icon: 'icon-shanchu',
      content: `确定要删除吗，删除后将无法恢复！`,
      okButtonProps: {
        pattern: 'error',
      },
      onOk: () => {
        return new Promise(async (resolve, reject) => {
          try {
            let res = await axios.request({
              url: '/${classname}',
              method: 'delete',
              params: {
                id: record.id,
              }
            });
            message.success(res.message);
            methods.searchQuery();
            resolve();
          } catch(error) {
            console.log('error', error);
            reject();
          }
        });
      },
    })
  },
};

methods.searchQuery();
</script>

<style lang="less" scoped>
</style>
