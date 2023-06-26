<template>
  <g-page-label title="安全组" icon="icon-rongqi">
    <template #tips>提供虚拟机内部服务向外暴露的方法和入口。</template>
  </g-page-label>

  <g-page-body>
    <template #header>
      <g-params :loading="tableState.loading" @search="methods.searchQuery()">
<#list columnList as column>	
        <!-- ${column.columnComment}搜索 -->
        <g-input
          v-model:value="queryParams.${column.columnName}"
          placeholder="输入${column.columnComment}搜索..."
          @keydown.enter="methods.searchQuery()"
        ></g-input>
</#list>
        <template #right>
          <g-button type="primary" @click="methods.showModify()">创建</g-button>
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

  <g-modal
    ref="modalRef"
    v-model:visible="modalState.visible"
    width="976px"
    :icon="modalState.icon"
    :title="modalState.title"
    :okText="modalState.okText"
    @ok="methods.onSubmit"
  >
    <g-form
      ref="formRef"
      name="formName"
      :model="formState"
      :rules="rules"
      autocomplete="off" layout="vertical"
    >
      <div class="grid grid-cols-2 gap-x-20px">
<#list columnList as column>
        <g-form-item label="${column.columnComment}" name="${column.columnName}">
          <g-input v-model:value="formState.${column.columnName}" placeholder="请输入"></g-input>
        </g-form-item>
</#list>
      </div>
    </g-form>
  </g-modal>
</template>

<script setup>
  import axios from '@/api';
  import {message} from 'ant-design-vue';
  import GModal from '@/components/global/modal/g-modal.jsx';
  import {changeHistoryState, initHistoryParams} from "@/utils/dispose";

  const formRef = ref();
const tableRef = ref();
// 表格请求参数
const queryParams = reactive({
  ...initHistoryParams({
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
// 弹窗信息
const modalState = reactive({
  visible: false,
  isCreate: true,
  icon: computed(() => modalState.isCreate ? 'icon-xinjian' : 'icon-bianji'),
  title: computed(() => modalState.isCreate ? '创建' : '编辑'),
  okText: computed(() => modalState.isCreate ? '创建' : '编辑'),
});
// 表单信息
const formState = reactive({
<#list columnList as column>
  ${column.columnName}: undefined,
</#list>
});
// 表单校验规则
const rules = {};

const methods = {
  // 搜索表格
  async searchQuery() {
    changeHistoryState(queryParams);
    // 磁盘列表（PVC列表）
    nextTick(() => {
      unref(tableRef).searchQuery({
        url: '/agent/search',
        method: 'get',
        data: queryParams,
      });
    });
  },
  // 显示弹窗
  showModify(record) {
    modalState.visible = true;
    modalState.isCreate = !record;
    Object.keys(formState).forEach(key => {
      formState[key] = modalState.isCreate ? undefined : record[key];
    });
  },
  onSubmit() {
    return new Promise((resolve, reject) => {
      // 校验表单
      try {
        unref(formRef).validate().then(async () => {
          let res = await axios.request({
            url: '/agent',
            method: modalState.isCreate ? 'post' : 'put',
            data: formState
          });
          message.success(res.message);
          methods.searchQuery();
          resolve();
        }).catch((error) => {
          console.log('validateError', error)
          reject()
        });
      } catch (error) {
        console.log('error', error);
        reject();
      }
    })
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
              url: '/agent',
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
