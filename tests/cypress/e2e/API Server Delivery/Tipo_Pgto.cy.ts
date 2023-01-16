describe('Rotas Tipo Pagamento', () => {
    let id01: number;
    let desc01: string;
    let id02:number;
    let desc02: string;

    it('Create Tipo Pagamento 01', () => {
        cy.request({
            method: 'POST',
            url: '/tipos-pagamento',
            body: {
                "id": 0,
                "descricao": 'PIX'
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Tipo de Pagamento adicionado com sucesso!');
            id01 = Response.body[1].id;
            desc01 = Response.body[1].descricao;
        });
    });

    it('Create Tipo Pagamento 02', () => {
        cy.request({
            method: 'POST',
            url: '/tipos-pagamento',
            body: {
                "id": 0,
                "descricao": 'DÉBITO'
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Tipo de Pagamento adicionado com sucesso!');
            id02 = Response.body[1].id;
            desc02 = Response.body[1].descricao;
        });
    });

    it('Get all Tipo Pagamento', () => {
        cy.request('/tipos-pagamento').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].id).to.equal(id01);
            expect(Response.body[0].descricao).to.equal(desc01);
            expect(Response.body[1].id).to.equal(id02);
            expect(Response.body[1].descricao).to.equal(desc02);
        });
    });

    it('Get Tipo Pagamento 01', () => {
        cy.request(`/tipos-pagamento/${id01}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id01);
            expect(Response.body.descricao).to.equal(desc01);
        });
    });

    it('Get Tipo Pagamento 02', () => {
        cy.request(`/tipos-pagamento/${id02}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id02);
            expect(Response.body.descricao).to.equal(desc02);
        });
    });

    it('Update Tipo Pagamento 01', () => {
        desc01 = 'Crédito';
        cy.request({
            method: 'PUT',
            url: `/tipos-pagamento/${id01}`,
            body: {
                "id": id01,
                "descricao": desc01
            }
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Tipo de Pagamento atualizado com sucesso!');
            expect(Response.body[1].descricao).to.equal(desc01);
            expect(Response.body[1].id).to.equal(id01);
        });
    });

    it('Update Tipo Pagamento 02', () => {
        desc02 = 'Dinheiro';
        cy.request({
            method: 'PUT',
            url: `/tipos-pagamento/${id02}`,
            body: {
                "id": id02,
                "descricao": desc02
            }
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Tipo de Pagamento atualizado com sucesso!');
            expect(Response.body[1].descricao).to.equal(desc02);
            expect(Response.body[1].id).to.equal(id02);
        });
    });

    it('Delete Tipo Pagamento 01', () => {
        cy.request({
            method: 'DELETE',
            url: `/tipos-pagamento/${id01}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('Tipo de Pagamento excluído com sucesso!');
        });
    });

    it('Delete Tipo Pagamento 02', () => {
        cy.request({
            method: 'DELETE',
            url: `/tipos-pagamento/${id02}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('Tipo de Pagamento excluído com sucesso!');
        });
    });
});